@echo off
echo ========================================
echo TMC Map - API配置更新助手
echo ========================================
echo.

echo 当前API配置信息：
echo.

echo 开发环境API地址：
echo - 本地调试: http://localhost:8080
echo - 手机调试: http://10.153.225.219:8080 (需要修改IP)
echo.

echo 生产环境API地址：
echo - 当前配置: https://api.tmcmap.com
echo.

echo 请按照以下步骤更新配置：
echo.

echo 1. 更新生产环境API地址
echo 编辑文件: uniapp-tmc-map/src/services/club.js
echo 找到第25行: return 'https://api.tmcmap.com'
echo 替换为你的微信云托管域名，例如：
echo return 'https://你的环境ID.service.tcloudbaseapp.com'
echo.

echo 2. 更新手机调试IP地址
echo 如果需要手机调试，编辑文件: uniapp-tmc-map/src/services/club.js
echo 找到第15行: const COMPUTER_IP = '10.153.225.219'
echo 替换为你电脑的实际IP地址
echo.

echo 3. 配置环境变量（可选）
echo 创建 .env.production 文件：
echo VUE_APP_API_BASE_URL=https://你的云托管域名
echo.

echo 4. 测试API连接
echo 部署完成后，运行以下命令测试：
echo curl https://你的云托管域名/api/clubs
echo.

echo 配置完成后，重新编译小程序即可生效。
echo.

pause 