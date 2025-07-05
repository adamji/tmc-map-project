@echo off
echo 配置Docker镜像源...

REM 创建.docker目录
if not exist "%USERPROFILE%\.docker" mkdir "%USERPROFILE%\.docker"

REM 创建daemon.json配置文件
echo {> "%USERPROFILE%\.docker\daemon.json"
echo   "registry-mirrors": [>> "%USERPROFILE%\.docker\daemon.json"
echo     "https://docker.mirrors.ustc.edu.cn",>> "%USERPROFILE%\.docker\daemon.json"
echo     "https://hub-mirror.c.163.com",>> "%USERPROFILE%\.docker\daemon.json"
echo     "https://mirror.baidubce.com">> "%USERPROFILE%\.docker\daemon.json"
echo   ],>> "%USERPROFILE%\.docker\daemon.json"
echo   "builder": {>> "%USERPROFILE%\.docker\daemon.json"
echo     "gc": {>> "%USERPROFILE%\.docker\daemon.json"
echo       "defaultKeepStorage": "20GB",>> "%USERPROFILE%\.docker\daemon.json"
echo       "enabled": true>> "%USERPROFILE%\.docker\daemon.json"
echo     }>> "%USERPROFILE%\.docker\daemon.json"
echo   },>> "%USERPROFILE%\.docker\daemon.json"
echo   "experimental": false>> "%USERPROFILE%\.docker\daemon.json"
echo }>> "%USERPROFILE%\.docker\daemon.json"

echo 配置文件已创建: %USERPROFILE%\.docker\daemon.json
echo.
echo 请重启Docker Desktop以使配置生效
echo 然后运行: docker info 来验证配置
pause 