@echo off
REM TMC Map GitHub部署脚本 (Windows版本)
REM 使用方法: deploy-to-github.bat [github-username] [repo-name]

setlocal enabledelayedexpansion

if "%~2"=="" (
    echo [ERROR] 使用方法: %0 [github-username] [repo-name]
    echo [INFO] 示例: %0 myusername tmc-map-project
    exit /b 1
)

set GITHUB_USERNAME=%1
set REPO_NAME=%2
set GITHUB_REPO=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git

echo [INFO] === TMC Map GitHub部署脚本 ===
echo [INFO] GitHub用户名: %GITHUB_USERNAME%
echo [INFO] 仓库名称: %REPO_NAME%
echo [INFO] 仓库地址: %GITHUB_REPO%

REM 检查必要工具
echo [INFO] 检查必要工具...

where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git未安装，请先安装Git
    exit /b 1
)

where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker未安装，请先安装Docker
    exit /b 1
)

where docker-compose >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose未安装，请先安装Docker Compose
    exit /b 1
)

REM 初始化Git仓库
echo [INFO] 初始化Git仓库...
if not exist ".git" (
    git init
    echo [INFO] Git仓库已初始化
) else (
    echo [WARN] Git仓库已存在
)

REM 添加远程仓库
echo [INFO] 配置远程仓库...
git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARN] 远程仓库已存在，更新URL...
    git remote set-url origin %GITHUB_REPO%
) else (
    git remote add origin %GITHUB_REPO%
    echo [INFO] 远程仓库已添加
)

REM 检查并创建必要的目录结构
echo [INFO] 检查目录结构...
if not exist "backend" (
    if exist "tmc-map-backend" (
        echo [INFO] 重新组织目录结构...
        mkdir backend
        mkdir frontend
        xcopy tmc-map-backend\* backend\ /E /I /H /Y
        xcopy uniapp-tmc-map\* frontend\ /E /I /H /Y
        echo [INFO] 目录结构已重新组织
    )
)

REM 添加所有文件到Git
echo [INFO] 添加文件到Git...
git add .

REM 提交代码
echo [INFO] 提交代码...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "timestamp=%YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%"

git commit -m "Deploy TMC Map project - %timestamp%"
if %errorlevel% neq 0 (
    echo [WARN] 没有新的提交
)

REM 推送到GitHub
echo [INFO] 推送代码到GitHub...
git push -u origin main
if %errorlevel% neq 0 (
    git push -u origin master
)

echo [INFO] 代码已成功推送到GitHub!

REM 构建Docker镜像
echo [INFO] 构建Docker镜像...
if exist "docker-compose.yml" (
    docker-compose build
    echo [INFO] Docker镜像构建完成
) else (
    echo [WARN] 未找到docker-compose.yml文件，跳过镜像构建
)

REM 测试本地部署
echo [INFO] 测试本地部署...
if exist "docker-compose.yml" (
    set /p choice="是否启动本地测试环境? (y/N): "
    if /i "!choice!"=="y" (
        docker-compose up -d
        echo [INFO] 本地环境已启动
        echo [INFO] 后端API: http://localhost:8080
        echo [INFO] 前端页面: http://localhost:80
        echo [INFO] 数据库: localhost:3306
    )
)

REM 生成下一步指南
echo [INFO] === 下一步操作指南 ===
echo [INFO] 1. 在GitHub仓库中配置以下Secrets:
echo [INFO]    - DOCKER_USERNAME: Docker Hub用户名
echo [INFO]    - DOCKER_PASSWORD: Docker Hub密码
echo [INFO]    - HOST: 服务器IP地址
echo [INFO]    - USERNAME: 服务器用户名
echo [INFO]    - KEY: 服务器SSH私钥
echo [INFO]
echo [INFO] 2. 配置WeChat Cloud Hosting (可选):
echo [INFO]    - CLOUDBASE_SECRET_KEY: 云开发密钥
echo [INFO]    - CLOUDBASE_ENV_ID: 云开发环境ID
echo [INFO]
echo [INFO] 3. 推送代码到main分支将自动触发部署
echo [INFO]
echo [INFO] GitHub仓库地址: %GITHUB_REPO%
echo [INFO] 部署完成! 🎉

pause 