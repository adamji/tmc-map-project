@echo off
REM 快速Docker测试脚本
REM 用于快速验证Docker环境是否正常工作

chcp 65001 >nul 2>&1

echo.
echo ========================================
echo   快速Docker环境测试
echo ========================================
echo.

REM 检查Docker
echo [1/4] 检查Docker安装...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker未安装
    echo 请访问: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)
echo ✅ Docker已安装

REM 检查Docker服务
echo.
echo [2/4] 检查Docker服务...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker服务未运行
    echo 请启动Docker Desktop
    pause
    exit /b 1
)
echo ✅ Docker服务正常

REM 测试Docker运行
echo.
echo [3/4] 测试Docker容器运行...
docker run --rm hello-world >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker容器运行失败
    pause
    exit /b 1
)
echo ✅ Docker容器运行正常

REM 检查Docker Compose
echo.
echo [4/4] 检查Docker Compose...
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose未安装
    pause
    exit /b 1
)
echo ✅ Docker Compose已安装

echo.
echo ========================================
echo   🎉 Docker环境测试通过！
echo ========================================
echo.
echo 现在可以运行完整测试脚本:
echo   test-docker-local.bat
echo.
echo 或者手动启动服务:
echo   docker-compose up -d
echo.

pause 