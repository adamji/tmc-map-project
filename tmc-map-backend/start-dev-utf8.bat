@echo off
chcp 65001
echo 设置控制台编码为UTF-8...

echo 启动TMC Map后端服务 (开发环境)...
echo =====================================


mvn spring-boot:run -Dspring-boot.run.profiles=dev -Dspring-boot.run.jvmArguments="-Dfile.encoding=UTF-8"
pause 