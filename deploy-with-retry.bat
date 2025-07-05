@echo off
echo 开始部署TMC Map后端服务...

REM 设置重试次数
set MAX_RETRIES=3
set RETRY_COUNT=0

:retry_build
echo 尝试构建Docker镜像 (第%RETRY_COUNT%次)...

REM 构建Docker镜像
docker build -f ./tmc-map-backend/Dockerfile -t tmc-map-backend:latest ./tmc-map-backend

REM 检查构建结果
if %ERRORLEVEL% EQU 0 (
    echo Docker镜像构建成功！
    goto success
) else (
    echo Docker镜像构建失败，错误代码: %ERRORLEVEL%
    set /a RETRY_COUNT+=1
    
    if %RETRY_COUNT% LSS %MAX_RETRIES% (
        echo 等待5秒后重试...
        timeout /t 5 /nobreak >nul
        goto retry_build
    ) else (
        echo 已达到最大重试次数，尝试使用备用Dockerfile...
        goto backup_build
    )
)

:backup_build
echo 使用备用Dockerfile构建...
docker build -f ./tmc-map-backend/Dockerfile.backup -t tmc-map-backend:latest ./tmc-map-backend

if %ERRORLEVEL% EQU 0 (
    echo 备用Dockerfile构建成功！
    goto success
) else (
    echo 备用Dockerfile也构建失败，请检查网络连接或Docker配置
    exit /b 1
)

:success
echo 构建完成，可以推送到云托管平台
echo 使用以下命令推送镜像：
echo docker tag tmc-map-backend:latest [你的镜像仓库地址]
echo docker push [你的镜像仓库地址]

pause 