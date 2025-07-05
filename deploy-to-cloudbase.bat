@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: TMC Map 微信云托管自动部署脚本 (Windows版)

echo 🚀 TMC Map 微信云托管自动部署脚本
echo ==================================

:: 检查是否在项目根目录
if not exist "tmc-map-backend" (
    echo ❌ 请在项目根目录运行此脚本
    pause
    exit /b 1
)

:: 检查必要工具
echo 📋 检查必要工具...

docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker 未安装，请先安装 Docker Desktop
    pause
    exit /b 1
)

npm --version >nul 2>&1
if errorlevel 1 (
    echo ❌ NPM 未安装，请先安装 Node.js
    pause
    exit /b 1
)

echo ✅ 工具检查通过

:: 安装 CloudBase CLI
echo 📋 安装 CloudBase CLI...

tcb --version >nul 2>&1
if errorlevel 1 (
    echo 正在安装 CloudBase CLI...
    npm install -g @cloudbase/cli
    if errorlevel 1 (
        echo ❌ CloudBase CLI 安装失败
        pause
        exit /b 1
    )
    echo ✅ CloudBase CLI 安装完成
) else (
    echo ✅ CloudBase CLI 已存在
)

:: 登录 CloudBase
echo 📋 登录 CloudBase...

tcb env:list >nul 2>&1
if errorlevel 1 (
    echo ⚠️ 需要登录 CloudBase，请按照提示完成登录
    tcb login
    if errorlevel 1 (
        echo ❌ 登录失败
        pause
        exit /b 1
    )
) else (
    echo ✅ 已登录 CloudBase
)

:: 构建 Docker 镜像
echo 📋 构建 Docker 镜像...

cd tmc-map-backend
docker build -t tmc-map-backend:latest .
if errorlevel 1 (
    echo ❌ 镜像构建失败
    cd ..
    pause
    exit /b 1
)

echo ✅ 镜像构建完成
cd ..

:: 测试镜像
echo 📋 测试 Docker 镜像...

docker run -d --name tmc-map-test -p 8080:8080 -e SPRING_PROFILES_ACTIVE=dev tmc-map-backend:latest
if errorlevel 1 (
    echo ❌ 镜像测试失败
    pause
    exit /b 1
)

:: 等待容器启动
echo 等待容器启动...
timeout /t 10 /nobreak >nul

:: 检查容器状态
docker ps | findstr "tmc-map-test" >nul
if errorlevel 1 (
    echo ❌ 镜像测试失败，请检查日志
    docker logs tmc-map-test
    docker stop tmc-map-test >nul 2>&1
    docker rm tmc-map-test >nul 2>&1
    pause
    exit /b 1
)

echo ✅ 镜像测试通过

:: 清理测试容器
docker stop tmc-map-test >nul
docker rm tmc-map-test >nul

:: 检查配置文件
if not exist "cloudbaserc.json" (
    echo ❌ cloudbaserc.json 文件不存在，请先配置
    echo 📋 请参考 CLOUDBASE_DEPLOYMENT_GUIDE.md 进行配置
    pause
    exit /b 1
)

:: 部署到云托管
echo 📋 部署到云托管...

tcb framework deploy
if errorlevel 1 (
    echo ❌ 部署失败
    pause
    exit /b 1
)

echo ✅ 部署完成

:: 获取访问地址
echo 📋 获取访问地址...
tcb service:list

echo.
echo 🎉 部署完成！
echo 📋 接下来需要手动完成：
echo    1. 配置数据库连接
echo    2. 配置环境变量
echo    3. 配置自定义域名（可选）
echo    4. 更新小程序前端 API 地址
echo.
echo 📖 详细步骤请参考：CLOUDBASE_DEPLOYMENT_GUIDE.md

pause 