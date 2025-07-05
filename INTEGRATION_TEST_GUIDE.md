# 头马俱乐部地图系统 - 集成测试指南

## 概述

本文档提供头马俱乐部地图系统的完整集成测试指南，包括后端API测试、前端功能测试和端到端测试。

## 测试环境

### 系统要求
- **操作系统**: Windows 10/11, macOS, Linux
- **Java**: JDK 17+
- **Node.js**: 18.x
- **Maven**: 3.8+
- **浏览器**: Chrome, Firefox, Safari
- **微信开发者工具**: 最新版

### 默认配置
- **默认城市**: 南京
- **默认坐标**: 纬度 32.0584, 经度 118.7964 (南京新街口)
- **后端服务**: http://localhost:8080
- **前端开发**: http://localhost:3000
- **API基础路径**: /api

## 1. 后端集成测试

### 1.1 启动后端服务

```bash
# 进入后端目录
cd tmc-map-backend

# 编译并启动服务
mvn clean compile spring-boot:run
```

**预期结果**:
- 服务在端口8080启动成功
- 控制台显示 "Started TmcMapApplication"
- 数据库初始化完成，插入15条俱乐部数据
- Swagger UI可访问: http://localhost:8080/swagger-ui.html

### 1.2 API功能测试

#### 1.2.1 获取所有俱乐部列表

**测试命令**:
```bash
curl -X GET "http://localhost:8080/api/clubs" -H "Content-Type: application/json"
```

**预期结果**:
```json
{
  "code": 0,
  "msg": "success",
  "data": [
    {
      "id": 1,
      "name": "南京新街口国际演讲俱乐部",
      "shortName": "新街口TMC",
      "address": "南京市鼓楼区中山北路26号新晨国际大厦18楼",
      "lat": 32.0584,
      "lng": 118.7964,
      "city": "南京",
      "meetingTime": "周一 19:30-21:30 双语",
      "meetingFormat": "双语",
      "contact": "Helen WANG",
      "contactPhone": "13951234567",
      "features": "位于新街口商圈核心，交通便利",
      "remarks": "欢迎各界人士加入"
    }
    // ... 更多俱乐部数据
  ]
}
```

#### 1.2.2 根据城市筛选俱乐部

**测试命令**:
```bash
curl -X GET "http://localhost:8080/api/clubs?city=南京" -H "Content-Type: application/json"
```

**预期结果**:
- 返回5个南京的俱乐部
- 所有俱乐部的city字段都是"南京"

#### 1.2.3 根据星期筛选俱乐部

**测试命令**:
```bash
curl -X GET "http://localhost:8080/api/clubs?weekday=6" -H "Content-Type: application/json"
```

**预期结果**:
- 返回周六有例会的俱乐部
- meetingTime字段包含"周六"

#### 1.2.4 获取附近俱乐部

**测试命令**:
```bash
curl -X GET "http://localhost:8080/api/clubs/nearby?lat=32.0584&lng=118.7964&radius=10" -H "Content-Type: application/json"
```

**预期结果**:
- 返回南京新街口10公里范围内的俱乐部
- 按距离从近到远排序

#### 1.2.5 获取俱乐部详情

**测试命令**:
```bash
curl -X GET "http://localhost:8080/api/clubs/1" -H "Content-Type: application/json"
```

**预期结果**:
- 返回ID为1的俱乐部详细信息
- 包含所有字段数据

#### 1.2.6 计算两点距离

**测试命令**:
```bash
curl -X GET "http://localhost:8080/api/navigation/distance?fromLat=32.0584&fromLng=118.7964&toLat=32.0751&toLng=118.7879" -H "Content-Type: application/json"
```

**预期结果**:
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "distance": 2.1,
    "unit": "km"
  }
}
```

#### 1.2.7 计算导航路线

**测试命令**:
```bash
curl -X POST "http://localhost:8080/api/navigation/calculate" \
  -H "Content-Type: application/json" \
  -d '{
    "fromLat": 32.0584,
    "fromLng": 118.7964,
    "toLat": 32.0751,
    "toLng": 118.7879,
    "mode": "driving"
  }'
```

**预期结果**:
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "distance": 2.1,
    "duration": 8,
    "mode": "driving",
    "steps": [
      {
        "instruction": "从起点出发",
        "distance": 0.5,
        "duration": 2
      }
    ]
  }
}
```

#### 1.2.8 错误处理测试

**获取不存在的俱乐部**:
```bash
curl -X GET "http://localhost:8080/api/clubs/999999" -H "Content-Type: application/json"
```

**预期结果**:
```json
{
  "code": 404,
  "msg": "俱乐部不存在或已被删除",
  "data": null
}
```

### 1.3 自动化测试脚本

**Windows用户**:
```bash
cd tmc-map-backend
test-api.bat
```

**Linux/macOS用户**:
```bash
cd tmc-map-backend
chmod +x test-api.sh
./test-api.sh
```

## 2. 前端集成测试

### 2.1 启动前端开发服务

```bash
# 进入前端目录
cd uniapp-tmc-map

# 安装依赖（首次运行）
npm install

# 启动微信小程序开发模式
npm run dev:mp-weixin
```

**预期结果**:
- 编译成功，无错误信息
- 生成 `dist/dev/mp-weixin` 目录
- 显示 "Run method: open Weixin Mini Program Devtools, import dist\dev\mp-weixin run."

### 2.2 微信开发者工具测试

#### 2.2.1 导入项目
1. 打开微信开发者工具
2. 选择"导入项目"
3. 项目目录选择: `uniapp-tmc-map/dist/dev/mp-weixin`
4. 填写AppID（测试号）

#### 2.2.2 首页功能测试

**测试步骤**:
1. 启动模拟器
2. 观察地图是否正常加载
3. 检查默认定位是否为南京新街口
4. 验证俱乐部标记是否显示

**预期结果**:
- 地图中心点: 南京新街口 (32.0584, 118.7964)
- 显示5个南京俱乐部标记
- 地图可以正常缩放和拖拽

#### 2.2.3 筛选功能测试

**日期筛选测试**:
1. 点击底部"请选择日期"按钮
2. 选择"周六"
3. 观察地图标记变化

**预期结果**:
- 只显示周六有例会的俱乐部
- 筛选按钮显示"周六"

**城市筛选测试**:
1. 点击底部城市按钮
2. 验证显示当前城市"南京"

#### 2.2.4 俱乐部详情测试

**测试步骤**:
1. 点击地图上的俱乐部标记
2. 观察俱乐部信息卡片
3. 点击"查看详情"

**预期结果**:
- 显示俱乐部名称、地址、例会时间
- 联系方式正确显示
- 详情页面加载正常

#### 2.2.5 导航功能测试

**测试步骤**:
1. 点击地图上的俱乐部标记
2. 在俱乐部信息卡片中点击"导航"按钮
3. 观察系统响应

**预期结果**:
- 正确调用系统地图应用
- 导航目标地址准确
- 导航功能响应正常

#### 2.2.6 定位功能测试

**测试步骤**:
1. 点击右下角定位按钮
2. 模拟器中选择位置权限
3. 观察地图中心变化

**预期结果**:
- 地图中心更新到当前位置
- 显示附近的俱乐部

### 2.3 环境变量测试

#### 2.3.1 开发环境测试

**验证开发环境配置**:
```bash
# 查看开发环境编译结果
cat dist/dev/mp-weixin/services/club.js
```

**预期结果**:
- API_BASE = "http://10.153.225.219:8080"（本地IP）

#### 2.3.2 生产环境测试

**生产环境编译**:
```bash
npm run build:mp-weixin
```

**验证生产环境配置**:
```bash
# 查看生产环境编译结果  
cat dist/build/mp-weixin/services/club.js
```

**预期结果**:
- API_BASE = "https://api.tmcmap.com"（生产环境）

## 3. 端到端集成测试

### 3.1 完整流程测试

#### 3.1.1 系统启动流程
1. 启动后端服务: `mvn spring-boot:run`
2. 启动前端开发: `npm run dev:mp-weixin`
3. 打开微信开发者工具
4. 导入项目目录

#### 3.1.2 用户使用流程
1. **打开小程序**: 验证首页加载
2. **查看地图**: 确认南京默认位置
3. **浏览俱乐部**: 点击标记查看信息
4. **筛选功能**: 按日期筛选俱乐部
5. **查看详情**: 进入俱乐部详情页
6. **导航功能**: 打开地图导航

### 3.2 数据一致性测试

#### 3.2.1 数据库与API一致性
```bash
# 查询数据库俱乐部数量
curl -X GET "http://localhost:8080/api/clubs" | jq '.data | length'
```

**预期结果**: 15个俱乐部

#### 3.2.2 前后端数据一致性
1. 后端API返回的俱乐部数据
2. 前端地图显示的标记数量
3. 筛选后的数据匹配

### 3.3 性能测试

#### 3.3.1 API响应时间
```bash
# 测试API响应时间
time curl -X GET "http://localhost:8080/api/clubs"
```

**预期结果**: 响应时间 < 500ms

#### 3.3.2 前端加载性能
- 首页加载时间 < 3秒
- 地图渲染时间 < 2秒
- 切换页面响应 < 1秒

## 4. 故障排除

### 4.1 常见问题

#### 后端启动失败
**问题**: 端口被占用
**解决**: 更改端口或结束占用进程

**问题**: 中文乱码
**解决**: 检查 `WebConfig.java` 字符编码配置

#### 前端编译失败
**问题**: Node.js版本不兼容
**解决**: 使用Node.js 18.x版本

**问题**: 环境变量未生效
**解决**: 清理dist目录重新编译

#### 微信开发者工具问题
**问题**: 网络请求失败
**解决**: 检查本地网络和后端服务状态

### 4.2 日志分析

#### 后端日志
- 查看控制台输出
- 检查API调用日志
- 确认SQL执行结果

#### 前端日志
- 微信开发者工具控制台
- 网络请求状态
- 编译错误信息

## 5. 测试报告模板

### 5.1 测试执行记录

| 测试项目 | 测试状态 | 执行时间 | 备注 |
|---------|---------|---------|------|
| 后端服务启动 | ✅ Pass | 30s | - |
| API功能测试 | ✅ Pass | 5min | 全部接口正常 |
| 前端编译 | ✅ Pass | 2min | - |
| 微信小程序功能 | ✅ Pass | 10min | 全部功能正常 |
| 数据一致性 | ✅ Pass | 3min | 前后端数据匹配 |
| 性能测试 | ✅ Pass | 5min | 响应时间满足要求 |

### 5.2 测试环境信息

- **测试时间**: 2025-01-XX XX:XX:XX
- **测试人员**: [姓名]
- **系统版本**: v1.0.0
- **测试环境**: Windows 11, Java 17, Node.js 18.19
- **浏览器**: Chrome 131.0.6778.86

### 5.3 测试结论

- **总体评估**: 系统功能完整，性能良好
- **发现问题**: [具体问题描述]
- **建议改进**: [改进建议]
- **发布建议**: ✅ 建议发布 / ❌ 不建议发布

## 6. 自动化测试脚本

完整的自动化测试可以通过以下脚本执行：

**Windows (PowerShell)**:
```powershell
# 完整集成测试脚本
.\full-integration-test.ps1
```

**Linux/macOS (Bash)**:
```bash
# 完整集成测试脚本
chmod +x full-integration-test.sh
./full-integration-test.sh
```

---

**注意**: 
1. 确保所有依赖服务正常运行
2. 网络连接稳定
3. 权限配置正确
4. 定期更新测试数据

如有问题，请参考故障排除章节或联系技术支持。 