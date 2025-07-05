@echo off
chcp 65001 >nul
title 头马俱乐部地图 - 热更新开发环境

echo === 头马俱乐部地图 - 热更新开发环境 ===
echo.
echo 🚀 正在启动热更新开发环境...
echo 📝 修改代码后会自动重新编译 (--watch 模式)
echo 🔄 请在微信开发者工具中打开项目：
echo    %cd%\dist\dev\mp-weixin
echo ⚡ 热更新功能：保存代码 → 自动编译 → 微信开发者工具自动刷新
echo.
echo 💡 使用 Ctrl+C 停止服务
echo.

REM 启动热更新开发环境
npm run dev:mp-weixin

pause 