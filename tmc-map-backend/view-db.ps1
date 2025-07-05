# 头马俱乐部地图系统 - 数据库查看工具 (PowerShell版本)

Write-Host "=== 头马俱乐部地图系统 - 数据库查看工具 ===" -ForegroundColor Green
Write-Host ""

# 1. 检查服务状态
Write-Host "1. 检查服务状态" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method Get
    Write-Host "服务状态: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "服务未启动或健康检查端点不存在" -ForegroundColor Red
}
Write-Host ""

# 2. 查看所有俱乐部数据
Write-Host "2. 查看所有俱乐部数据" -ForegroundColor Yellow
try {
    $clubs = Invoke-RestMethod -Uri "http://localhost:8080/api/clubs" -Method Get
    Write-Host "总俱乐部数量: $($clubs.data.Count)" -ForegroundColor Green
    
    # 显示前3个俱乐部
    for ($i = 0; $i -lt [Math]::Min(3, $clubs.data.Count); $i++) {
        $club = $clubs.data[$i]
        Write-Host "  ID: $($club.id), 名称: $($club.name), 城市: $($club.city)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "获取俱乐部数据失败: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 3. 查看南京俱乐部
Write-Host "3. 查看南京俱乐部" -ForegroundColor Yellow
try {
    $nanjingClubs = Invoke-RestMethod -Uri "http://localhost:8080/api/clubs?city=南京" -Method Get
    Write-Host "南京俱乐部数量: $($nanjingClubs.data.Count)" -ForegroundColor Green
    
    foreach ($club in $nanjingClubs.data) {
        Write-Host "  ID: $($club.id), 名称: $($club.name)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "获取南京俱乐部数据失败: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 4. 数据库访问信息
Write-Host "=== 数据库访问方式 ===" -ForegroundColor Green
Write-Host ""
Write-Host "H2控制台: http://localhost:8080/h2-console" -ForegroundColor Yellow
Write-Host "JDBC URL: jdbc:h2:mem:tmc_map" -ForegroundColor Yellow
Write-Host "用户名: sa" -ForegroundColor Yellow
Write-Host "密码: (留空)" -ForegroundColor Yellow
Write-Host ""
Write-Host "在H2控制台中执行以下SQL查看数据:" -ForegroundColor Cyan
Write-Host "SELECT * FROM club;" -ForegroundColor White
Write-Host "SELECT * FROM club WHERE city = '南京';" -ForegroundColor White
Write-Host ""

# 5. 编码问题诊断
Write-Host "=== 编码问题诊断 ===" -ForegroundColor Green
Write-Host ""
Write-Host "如果数据显示乱码，可能的原因:" -ForegroundColor Yellow
Write-Host "1. 数据文件编码不是UTF-8" -ForegroundColor Red
Write-Host "2. 数据库连接字符集配置错误" -ForegroundColor Red
Write-Host "3. 应用启动时的字符编码设置问题" -ForegroundColor Red
Write-Host ""
Write-Host "修复建议:" -ForegroundColor Yellow
Write-Host "1. 访问H2控制台手动查看和修复数据" -ForegroundColor Cyan
Write-Host "2. 重新启动服务" -ForegroundColor Cyan
Write-Host "3. 检查data-h2.sql文件的编码格式" -ForegroundColor Cyan
Write-Host ""

Read-Host "按回车键继续..." 