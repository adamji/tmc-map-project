@echo off
chcp 65001 >nul
echo ========================================
echo 数据库版本管理功能测试
echo ========================================

echo.
echo 1. 启动应用...
start /B mvn spring-boot:run -Dspring-boot.run.profiles=dev

echo.
echo 等待应用启动...
timeout /t 10 /nobreak > nul

echo.
echo 2. 测试迁移状态API...
curl -s http://localhost:8080/api/migration/status
echo.

echo.
echo 3. 查看迁移历史...
curl -s http://localhost:8080/api/migration/history
echo.

echo.
echo 4. 访问H2控制台查看数据库...
echo 请打开浏览器访问: http://localhost:8080/h2-console
echo 连接信息:
echo - JDBC URL: jdbc:h2:mem:testdb
echo - 用户名: sa
echo - 密码: (留空)
echo.

echo.
echo 5. 查看数据库表...
echo 在H2控制台中执行以下SQL:
echo SELECT * FROM db_version;
echo SELECT * FROM club;
echo.

echo.
echo 6. 测试手动执行迁移...
curl -X POST http://localhost:8080/api/migration/execute
echo.

echo.
echo 测试完成！按任意键退出...
pause > nul 