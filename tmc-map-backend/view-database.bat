@echo off
chcp 65001 >nul
REM 查看数据库内容并提供修复方案

echo === 头马俱乐部地图系统 - 数据库查看工具 ===
echo.

echo 1. 检查服务状态
curl -s "http://localhost:8080/actuator/health"
echo.
echo.

echo 2. 查看数据库中的俱乐部数据（显示前3条）
echo 注意：如果显示乱码，说明数据库编码有问题
curl -s "http://localhost:8080/api/clubs" | findstr /C:"name" /C:"city" | findstr /C:"南京" /C:"深圳" | head -10
echo.
echo.

echo 3. 查看南京俱乐部数量
curl -s "http://localhost:8080/api/clubs?city=南京" | findstr /C:"id"
echo.
echo.

echo === 数据库访问方式 ===
echo.
echo H2控制台: http://localhost:8080/h2-console
echo JDBC URL: jdbc:h2:mem:tmc_map
echo 用户名: sa
echo 密码: (留空)
echo.
echo 在H2控制台中执行以下SQL查看数据:
echo SELECT * FROM club;
echo SELECT * FROM club WHERE city = '南京';
echo.
echo === 编码问题修复方案 ===
echo.
echo 如果数据是乱码，需要:
echo 1. 停止服务
echo 2. 删除target目录
echo 3. 重新编译并启动
echo 4. 或者直接访问H2控制台手动修复数据
echo.
pause 