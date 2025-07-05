@echo off
echo ========================================
echo TMC Map - 云托管数据库配置助手
echo ========================================
echo.

echo 使用微信云托管自带数据库的优势：
echo ✓ 无需额外配置，与容器服务在同一VPC
echo ✓ 自动备份功能
echo ✓ 完善的监控指标
echo ✓ 按实际使用量计费
echo ✓ 内置安全防护
echo.

echo 配置步骤：
echo.

echo 第一步：在云托管控制台创建数据库
echo 1. 访问 https://cloud.weixin.qq.com/
echo 2. 选择你的环境
echo 3. 进入"数据库"页面
echo 4. 点击"新建数据库"
echo 5. 选择"MySQL"
echo 6. 配置信息：
echo    - 数据库名：tmc_map
echo    - 用户名：tmc_user（或自定义）
echo    - 密码：设置强密码
echo    - 端口：3306
echo 7. 点击"确定"创建
echo.

echo 第二步：获取数据库连接信息
echo 创建完成后，记录以下信息：
echo - 数据库地址（如：mysql-xxxxx.service.tcloudbaseapp.com）
echo - 用户名
echo - 密码
echo.

echo 第三步：更新配置文件
echo 1. 编辑 tmc-map-backend/src/main/resources/application-prod.yml
echo 2. 更新数据库连接信息：
echo    - 替换"你的云托管数据库地址"
echo    - 替换"你的数据库用户名"
echo    - 替换"你的数据库密码"
echo.

echo 第四步：部署服务
echo 运行以下命令：
echo npm install -g @cloudbase/cli
echo tcb login
echo tcb framework deploy
echo.

echo 第五步：验证部署
echo 1. 在云托管控制台查看服务状态
echo 2. 测试API接口：
echo    curl https://你的云托管域名/api/clubs
echo 3. 检查数据库连接日志
echo.

echo 注意事项：
echo - 数据库只能通过内网访问
echo - 使用强密码，定期更换
echo - 关注数据库性能监控
echo - 定期备份重要数据
echo.

echo 配置完成后，Spring Boot会自动创建表结构。
echo 如需手动初始化数据，可在云托管控制台执行SQL脚本。
echo.

pause 