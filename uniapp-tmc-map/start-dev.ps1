# 头马俱乐部地图 - 热更新开发环境启动脚本

Write-Host "=== 头马俱乐部地图 - 热更新开发环境 ===" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 正在启动热更新开发环境..." -ForegroundColor Yellow
Write-Host "📝 修改代码后会自动重新编译 (--watch 模式)" -ForegroundColor Cyan
Write-Host "🔄 请在微信开发者工具中打开项目：" -ForegroundColor Cyan
Write-Host "   $PWD\dist\dev\mp-weixin" -ForegroundColor White
Write-Host "⚡ 热更新功能：保存代码 → 自动编译 → 微信开发者工具自动刷新" -ForegroundColor Green
Write-Host ""
Write-Host "💡 使用 Ctrl+C 停止服务" -ForegroundColor Yellow
Write-Host ""

# 启动热更新开发环境
npm run dev:mp-weixin 