@echo off
echo ========================================
echo TMC Map - 微信云托管配置助手
echo ========================================
echo.

echo 请按照以下步骤配置微信云托管环境：
echo.

echo 第一步：开通微信云托管
echo 1. 访问 https://cloud.weixin.qq.com/
echo 2. 使用微信开发者账号登录
echo 3. 选择你的小程序项目
echo 4. 点击"开通云托管"
echo 5. 选择计费方式（建议按量计费）
echo 6. 选择地域（建议选择离用户最近的地域）
echo.

echo 第二步：获取环境信息
echo 1. 在云托管控制台找到"环境ID"
echo 2. 复制环境ID（格式类似：prod-xxxxxx）
echo 3. 创建MySQL数据库
echo 4. 记录数据库连接信息
echo.

echo 第三步：更新配置文件
echo 请手动更新以下文件：
echo 1. cloudbaserc.json - 替换环境ID
echo 2. application-prod.yml - 更新数据库配置
echo.

echo 第四步：安装云托管CLI
echo 运行以下命令：
echo npm install -g @cloudbase/cli
echo tcb login
echo.

echo 第五步：部署服务
echo 运行以下命令：
echo tcb framework deploy
echo.

echo 配置完成后，请运行以下命令测试：
echo curl https://你的云托管域名/api/clubs
echo.

pause 