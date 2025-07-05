@echo off
echo ========================================
echo TMC Map 后端部署快速修复脚本
echo ========================================

echo.
echo 正在检查当前状态...

REM 检查Docker是否运行
docker version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 错误: Docker未运行，请启动Docker Desktop
    pause
    exit /b 1
)

echo Docker运行正常

echo.
echo 选择部署方案:
echo 1. 使用简化版Dockerfile (推荐，无网络依赖)
echo 2. 使用备用Dockerfile (带进程健康检查)
echo 3. 使用主Dockerfile (带HTTP健康检查，可能遇到网络问题)
echo 4. 退出

set /p choice="请输入选择 (1-4): "

if "%choice%"=="1" goto simple_build
if "%choice%"=="2" goto backup_build
if "%choice%"=="3" goto main_build
if "%choice%"=="4" goto exit
echo 无效选择，使用默认方案1
goto simple_build

:simple_build
echo.
echo 使用简化版Dockerfile构建...
docker build -f ./tmc-map-backend/Dockerfile.simple -t tmc-map-backend:latest ./tmc-map-backend
if %ERRORLEVEL% EQU 0 goto success
echo 简化版构建失败，尝试备用方案...
goto backup_build

:backup_build
echo.
echo 使用备用Dockerfile构建...
docker build -f ./tmc-map-backend/Dockerfile.backup -t tmc-map-backend:latest ./tmc-map-backend
if %ERRORLEVEL% EQU 0 goto success
echo 备用方案也失败，尝试主方案...
goto main_build

:main_build
echo.
echo 使用主Dockerfile构建...
docker build -f ./tmc-map-backend/Dockerfile -t tmc-map-backend:latest ./tmc-map-backend
if %ERRORLEVEL% EQU 0 goto success
echo 所有构建方案都失败了
goto failure

:success
echo.
echo ========================================
echo 构建成功！
echo ========================================
echo.
echo 镜像信息:
docker images tmc-map-backend:latest
echo.
echo 下一步操作:
echo 1. 本地测试: docker run -p 8080:8080 tmc-map-backend:latest
echo 2. 推送到云托管: 参考 DEPLOYMENT_TROUBLESHOOTING.md
echo.
goto exit

:failure
echo.
echo ========================================
echo 构建失败！
echo ========================================
echo.
echo 可能的解决方案:
echo 1. 检查网络连接
echo 2. 重启Docker Desktop
echo 3. 清理Docker缓存: docker system prune -a
echo 4. 查看详细错误信息
echo.
echo 参考 DEPLOYMENT_TROUBLESHOOTING.md 获取更多帮助

:exit
echo.
echo 按任意键退出...
pause >nul 