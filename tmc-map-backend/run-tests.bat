@echo off
chcp 65001 >nul
echo ========================================
echo 数据库版本管理功能单元测试
echo ========================================

echo.
echo 1. 清理之前的测试结果...
if exist target\test-results rmdir /s /q target\test-results

echo.
echo 2. 运行单元测试...
mvn test -Dtest=DatabaseMigrationServiceTest,DatabaseMigrationControllerTest

echo.
echo 3. 生成测试报告...
mvn surefire-report:report

echo.
echo 4. 查看测试结果...
if exist target\site\surefire-report.html (
    echo 测试报告已生成: target\site\surefire-report.html
    start target\site\surefire-report.html
) else (
    echo 测试报告生成失败
)

echo.
echo 测试完成！按任意键退出...
pause > nul 