#!/bin/bash

# TMC Map GitHub部署脚本
# 使用方法: ./deploy-to-github.sh [github-username] [repo-name]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印彩色输出
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -lt 2 ]; then
    print_error "使用方法: $0 [github-username] [repo-name]"
    print_info "示例: $0 myusername tmc-map-project"
    exit 1
fi

GITHUB_USERNAME=$1
REPO_NAME=$2
GITHUB_REPO="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

print_info "=== TMC Map GitHub部署脚本 ==="
print_info "GitHub用户名: ${GITHUB_USERNAME}"
print_info "仓库名称: ${REPO_NAME}"
print_info "仓库地址: ${GITHUB_REPO}"

# 检查必要工具
check_tool() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安装，请先安装"
        exit 1
    fi
}

print_info "检查必要工具..."
check_tool git
check_tool docker
check_tool docker-compose

# 初始化Git仓库
print_info "初始化Git仓库..."
if [ ! -d ".git" ]; then
    git init
    print_info "Git仓库已初始化"
else
    print_warn "Git仓库已存在"
fi

# 添加远程仓库
print_info "配置远程仓库..."
if git remote get-url origin &> /dev/null; then
    print_warn "远程仓库已存在，更新URL..."
    git remote set-url origin $GITHUB_REPO
else
    git remote add origin $GITHUB_REPO
    print_info "远程仓库已添加"
fi

# 检查并创建必要的目录结构
print_info "检查目录结构..."
if [ ! -d "backend" ] && [ -d "tmc-map-backend" ]; then
    print_info "重新组织目录结构..."
    mkdir -p backend frontend
    cp -r tmc-map-backend/* backend/
    cp -r uniapp-tmc-map/* frontend/
    print_info "目录结构已重新组织"
fi

# 添加所有文件到Git
print_info "添加文件到Git..."
git add .

# 检查是否有变更
if git diff --cached --quiet; then
    print_warn "没有检测到文件变更"
else
    print_info "检测到文件变更，准备提交"
fi

# 提交代码
print_info "提交代码..."
COMMIT_MSG="Deploy TMC Map project - $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG" || print_warn "没有新的提交"

# 推送到GitHub
print_info "推送代码到GitHub..."
git push -u origin main || git push -u origin master

print_info "代码已成功推送到GitHub!"

# 构建Docker镜像
print_info "构建Docker镜像..."
if [ -f "docker-compose.yml" ]; then
    docker-compose build
    print_info "Docker镜像构建完成"
else
    print_warn "未找到docker-compose.yml文件，跳过镜像构建"
fi

# 测试本地部署
print_info "测试本地部署..."
if [ -f "docker-compose.yml" ]; then
    read -p "是否启动本地测试环境? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose up -d
        print_info "本地环境已启动"
        print_info "后端API: http://localhost:8080"
        print_info "前端页面: http://localhost:80"
        print_info "数据库: localhost:3306"
    fi
fi

# 生成下一步指南
print_info "=== 下一步操作指南 ==="
print_info "1. 在GitHub仓库中配置以下Secrets:"
print_info "   - DOCKER_USERNAME: Docker Hub用户名"
print_info "   - DOCKER_PASSWORD: Docker Hub密码"
print_info "   - HOST: 服务器IP地址"
print_info "   - USERNAME: 服务器用户名"
print_info "   - KEY: 服务器SSH私钥"
print_info ""
print_info "2. 配置WeChat Cloud Hosting (可选):"
print_info "   - CLOUDBASE_SECRET_KEY: 云开发密钥"
print_info "   - CLOUDBASE_ENV_ID: 云开发环境ID"
print_info ""
print_info "3. 推送代码到main分支将自动触发部署"
print_info ""
print_info "GitHub仓库地址: $GITHUB_REPO"
print_info "部署完成! 🎉" 