@echo off
echo ========================================
echo 健康检查测试脚本
echo ========================================

echo 1. 检查应用是否运行...
netstat -an | findstr :8080
if %errorlevel% neq 0 (
    echo 错误: 应用未在8080端口运行
    echo 请先启动应用: mvn spring-boot:run -Dspring-boot.run.profiles=prod
    pause
    exit /b 1
)

echo 2. 测试Spring Boot Actuator健康检查...
curl -f http://localhost:8080/api/actuator/health
if %errorlevel% equ 0 (
    echo ✅ Actuator健康检查通过
) else (
    echo ❌ Actuator健康检查失败
)

echo.
echo 3. 测试自定义健康检查...
curl -f http://localhost:8080/api/health
if %errorlevel% equ 0 (
    echo ✅ 自定义健康检查通过
) else (
    echo ❌ 自定义健康检查失败
)

echo.
echo 4. 测试根路径...
curl -f http://localhost:8080/api/
if %errorlevel% equ 0 (
    echo ✅ 根路径检查通过
) else (
    echo ❌ 根路径检查失败
)

echo.
echo 5. 测试俱乐部API...
curl -f http://localhost:8080/api/clubs
if %errorlevel% equ 0 (
    echo ✅ 俱乐部API检查通过
) else (
    echo ❌ 俱乐部API检查失败
)

echo.
echo ========================================
echo 健康检查测试完成
echo ========================================
pause 