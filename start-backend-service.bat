@echo off
echo ================================
echo TMC Map Backend 服务启动脚本
echo ================================
echo.

REM 设置变量
set BACKEND_DIR=tmc-map-backend
set JAR_NAME=tmc-map-backend-1.0.0.jar
set JAVA_OPTS=-Xmx512m -Xms256m
set SPRING_PROFILE=dev
set SERVER_PORT=8080
set LOG_FILE=backend.log

echo 检查Java环境...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到Java环境
    pause
    exit /b 1
)

echo 检查JAR文件...
if not exist "%BACKEND_DIR%\target\%JAR_NAME%" (
    echo 错误: JAR文件不存在，请先运行构建
    echo 运行: deploy-jar-local.bat
    pause
    exit /b 1
)

echo 启动后台服务...
cd %BACKEND_DIR%

REM 使用start命令在新窗口中启动服务
start "TMC Map Backend" /min java %JAVA_OPTS% -Dspring.profiles.active=%SPRING_PROFILE% -Dserver.port=%SERVER_PORT% -jar target\%JAR_NAME% > %LOG_FILE% 2>&1

echo.
echo 服务已在后台启动
echo 端口: %SERVER_PORT%
echo 日志文件: %BACKEND_DIR%\%LOG_FILE%
echo.
echo 测试服务:
echo   curl http://localhost:%SERVER_PORT%/actuator/health
echo   或访问: http://localhost:%SERVER_PORT%/actuator/health
echo.
echo 停止服务: 关闭"TMC Map Backend"窗口或使用任务管理器
echo.

REM 等待服务启动
timeout /t 3 /nobreak >nul

REM 测试服务健康状态
echo 正在测试服务状态...
curl -s http://localhost:%SERVER_PORT%/actuator/health 2>nul
if %errorlevel% equ 0 (
    echo 服务启动成功！
) else (
    echo 服务可能还在启动中，请稍后手动测试
)

pause 