@echo off
chcp 65001 >nul
REM 头马俱乐部地图系统 - 开发环境启动脚本

echo === 头马俱乐部地图系统 - 开发环境启动 ===
echo.
echo 正在启动开发环境...
echo 配置文件: application-dev.yml
echo 编码设置: UTF-8
echo.

REM 启动Spring Boot应用
mvn spring-boot:run -D"spring-boot.run.profiles=dev" -D"spring-boot.run.jvmArguments=-Dfile.encoding=UTF-8" 