@echo off
echo ================================
echo TMC Map Backend 本地部署脚本
echo ================================
echo.

REM 设置变量
set BACKEND_DIR=tmc-map-backend
set JAR_NAME=tmc-map-backend-1.0.0.jar
set JAVA_OPTS=-Xmx512m -Xms256m
set SPRING_PROFILE=dev
set SERVER_PORT=8080

echo 1. 检查Java环境...
java -version
if %errorlevel% neq 0 (
    echo 错误: 未找到Java环境，请安装Java 17或更高版本
    pause
    exit /b 1
)

echo.
echo 2. 构建Spring Boot应用...
cd %BACKEND_DIR%
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo 错误: Maven构建失败
    pause
    exit /b 1
)

echo.
echo 3. 检查JAR文件...
if not exist "target\%JAR_NAME%" (
    echo 错误: JAR文件不存在: target\%JAR_NAME%
    pause
    exit /b 1
)

echo.
echo 4. 启动应用...
echo 应用将在端口 %SERVER_PORT% 启动
echo 使用配置文件: %SPRING_PROFILE%
echo Java选项: %JAVA_OPTS%
echo.
echo 按Ctrl+C停止应用
echo.

java %JAVA_OPTS% -Dspring.profiles.active=%SPRING_PROFILE% -Dserver.port=%SERVER_PORT% -jar target\%JAR_NAME%

echo.
echo 应用已停止
pause 