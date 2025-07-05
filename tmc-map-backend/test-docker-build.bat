@echo off
echo ========================================
echo Docker构建测试脚本
echo ========================================

echo 1. 测试主要Dockerfile...
docker build -t tmc-map-backend:main .
if %errorlevel% neq 0 (
    echo ❌ 主要Dockerfile构建失败
    echo 尝试简化版Dockerfile...
    docker build -f Dockerfile.simple -t tmc-map-backend:simple .
    if %errorlevel% neq 0 (
        echo ❌ 简化版Dockerfile也构建失败
        echo 请检查Docker环境和网络连接
        pause
        exit /b 1
    ) else (
        echo ✅ 简化版Dockerfile构建成功
        set DOCKERFILE_TYPE=simple
    )
) else (
    echo ✅ 主要Dockerfile构建成功
    set DOCKERFILE_TYPE=main
)

echo.
echo 2. 测试容器启动...
if "%DOCKERFILE_TYPE%"=="simple" (
    docker run --rm -d --name tmc-test -p 8080:8080 -e SPRING_PROFILES_ACTIVE=test tmc-map-backend:simple
) else (
    docker run --rm -d --name tmc-test -p 8080:8080 -e SPRING_PROFILES_ACTIVE=test tmc-map-backend:main
)

echo 等待应用启动...
timeout /t 30 /nobreak > nul

echo.
echo 3. 测试健康检查...
curl http://localhost:8080/api/health
if %errorlevel% equ 0 (
    echo ✅ 健康检查通过
) else (
    echo ❌ 健康检查失败
    echo 查看容器日志:
    docker logs tmc-test
)

echo.
echo 4. 清理测试容器...
docker stop tmc-test

echo.
echo ========================================
echo 测试完成
echo ========================================
pause 