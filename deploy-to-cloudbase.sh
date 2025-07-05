#!/bin/bash

# TMC Map 微信云托管自动部署脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}📋 $1${NC}"
}

# 检查必要工具
check_tools() {
    print_info "检查必要工具..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "NPM 未安装，请先安装 Node.js"
        exit 1
    fi
    
    print_success "工具检查通过"
}

# 安装 CloudBase CLI
install_cli() {
    print_info "安装 CloudBase CLI..."
    
    if ! command -v tcb &> /dev/null; then
        npm install -g @cloudbase/cli
        print_success "CloudBase CLI 安装完成"
    else
        print_success "CloudBase CLI 已存在"
    fi
}

# 登录 CloudBase
login_cloudbase() {
    print_info "登录 CloudBase..."
    
    if ! tcb env:list &> /dev/null; then
        print_warning "需要登录 CloudBase，请按照提示完成登录"
        tcb login
    else
        print_success "已登录 CloudBase"
    fi
}

# 构建 Docker 镜像
build_image() {
    print_info "构建 Docker 镜像..."
    
    cd tmc-map-backend
    
    # 构建镜像
    docker build -t tmc-map-backend:latest .
    
    print_success "镜像构建完成"
    
    cd ..
}

# 测试镜像
test_image() {
    print_info "测试 Docker 镜像..."
    
    # 启动容器进行测试
    docker run -d --name tmc-map-test -p 8080:8080 -e SPRING_PROFILES_ACTIVE=dev tmc-map-backend:latest
    
    sleep 10
    
    # 检查容器状态
    if docker ps | grep -q tmc-map-test; then
        print_success "镜像测试通过"
    else
        print_error "镜像测试失败，请检查日志"
        docker logs tmc-map-test
        exit 1
    fi
    
    # 清理测试容器
    docker stop tmc-map-test
    docker rm tmc-map-test
}

# 部署到云托管
deploy_to_cloudbase() {
    print_info "部署到云托管..."
    
    # 检查配置文件
    if [[ ! -f "cloudbaserc.json" ]]; then
        print_error "cloudbaserc.json 文件不存在，请先配置"
        exit 1
    fi
    
    # 执行部署
    tcb framework deploy
    
    print_success "部署完成"
}

# 获取访问地址
get_access_url() {
    print_info "获取访问地址..."
    
    # 列出服务
    tcb service:list
    
    print_success "部署完成！请查看上方的访问地址"
}

# 主函数
main() {
    echo "🚀 TMC Map 微信云托管自动部署脚本"
    echo "=================================="
    
    # 检查是否在项目根目录
    if [[ ! -d "tmc-map-backend" ]]; then
        print_error "请在项目根目录运行此脚本"
        exit 1
    fi
    
    # 执行部署步骤
    check_tools
    install_cli
    login_cloudbase
    build_image
    test_image
    deploy_to_cloudbase
    get_access_url
    
    echo ""
    echo "🎉 部署完成！"
    echo "📋 接下来需要手动完成："
    echo "   1. 配置数据库连接"
    echo "   2. 配置环境变量"
    echo "   3. 配置自定义域名（可选）"
    echo "   4. 更新小程序前端 API 地址"
    echo ""
    echo "📖 详细步骤请参考：CLOUDBASE_DEPLOYMENT_GUIDE.md"
}

# 执行主函数
main "$@" 