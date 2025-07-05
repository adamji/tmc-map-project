@echo off
REM TMC Map 本地Docker测试脚本
REM 自动构建、启动和测试Docker环境

chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   TMC Map 本地Docker测试脚本
echo ========================================
echo.

REM 检查Docker是否安装
echo [INFO] 检查Docker安装...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker未安装！
    echo [INFO] 请先安装Docker Desktop: https://www.docker.com/products/docker-desktop/
    echo [INFO] 安装完成后重新运行此脚本
    pause
    exit /b 1
)
echo ✅ Docker已安装

REM 检查Docker是否运行
echo.
echo [INFO] 检查Docker服务状态...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker服务未运行！
    echo [INFO] 请启动Docker Desktop并等待其完全启动
    pause
    exit /b 1
)
echo ✅ Docker服务运行正常

REM 检查端口占用
echo.
echo [INFO] 检查端口占用情况...
netstat -ano | findstr :8080 >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARN] 端口8080被占用，尝试停止占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
        taskkill /PID %%a /F >nul 2>&1
    )
)

netstat -ano | findstr :80 >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARN] 端口80被占用，尝试停止占用进程...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :80') do (
        taskkill /PID %%a /F >nul 2>&1
    )
)

echo ✅ 端口检查完成

REM 停止现有容器
echo.
echo [INFO] 停止现有容器...
docker-compose down >nul 2>&1
echo ✅ 现有容器已停止

REM 构建后端镜像
echo.
echo [INFO] 构建后端Docker镜像...
cd tmc-map-backend
docker build -t tmc-map-backend:local .
if %errorlevel% neq 0 (
    echo [ERROR] 后端镜像构建失败！
    cd ..
    pause
    exit /b 1
)
echo ✅ 后端镜像构建成功
cd ..

REM 构建前端镜像
echo.
echo [INFO] 构建前端Docker镜像...
cd uniapp-tmc-map
docker build -t tmc-map-frontend:local .
if %errorlevel% neq 0 (
    echo [ERROR] 前端镜像构建失败！
    cd ..
    pause
    exit /b 1
)
echo ✅ 前端镜像构建成功
cd ..

REM 启动所有服务
echo.
echo [INFO] 启动所有Docker服务...
docker-compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] 服务启动失败！
    pause
    exit /b 1
)
echo ✅ 所有服务启动成功

REM 等待服务启动
echo.
echo [INFO] 等待服务完全启动...
timeout /t 30 /nobreak >nul

REM 检查服务状态
echo.
echo [INFO] 检查服务状态...
docker-compose ps

REM 测试后端API
echo.
echo [INFO] 测试后端API...
timeout /t 5 /nobreak >nul
curl -f http://localhost:8080/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 后端API健康检查通过
) else (
    echo ⚠️  后端API健康检查失败，请检查日志
)

REM 测试前端页面
echo.
echo [INFO] 测试前端页面...
curl -f http://localhost:80 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 前端页面可访问
) else (
    echo ⚠️  前端页面访问失败，请检查日志
)

REM 显示访问信息
echo.
echo ========================================
echo   🎉 本地Docker测试环境启动成功！
echo ========================================
echo.
echo 📍 访问地址:
echo   后端API: http://localhost:8080
echo   前端页面: http://localhost:80
echo   数据库: localhost:3306
echo.
echo 📋 常用命令:
echo   查看日志: docker-compose logs
echo   停止服务: docker-compose down
echo   重启服务: docker-compose restart
echo   查看状态: docker-compose ps
echo.
echo 🔍 测试API:
echo   curl http://localhost:8080/api/clubs
echo   curl http://localhost:8080/actuator/health
echo.

REM 询问是否查看日志
set /p view_logs="是否查看服务日志? (y/N): "
if /i "!view_logs!"=="y" (
    echo.
    echo [INFO] 显示服务日志...
    docker-compose logs --tail=20
)

echo.
echo [INFO] 本地Docker测试环境设置完成！
echo [INFO] 现在可以在浏览器中访问 http://localhost:80 测试应用
echo.

pause 