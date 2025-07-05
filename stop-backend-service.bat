@echo off
echo ================================
echo TMC Map Backend 服务停止脚本
echo ================================
echo.

echo 查找Java进程...
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq java.exe" /fo csv ^| find "java.exe"') do (
    echo 找到Java进程: %%i
    taskkill /pid %%i /f >nul 2>&1
    if %errorlevel% equ 0 (
        echo 已停止进程: %%i
    )
)

echo.
echo 查找TMC Map Backend窗口...
taskkill /fi "windowtitle eq TMC Map Backend*" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo 已停止TMC Map Backend窗口
)

echo.
echo 检查端口8080是否被占用...
netstat -ano | findstr :8080 >nul 2>&1
if %errorlevel% equ 0 (
    echo 端口8080仍被占用，请手动检查
    netstat -ano | findstr :8080
) else (
    echo 端口8080已释放
)

echo.
echo 服务停止完成
pause 