# 微信云托管环境配置指南

## 概述
本指南将帮助你在微信云托管上部署TMC Map项目的后端服务。

## 前置条件
- 微信开发者账号
- 已创建小程序项目
- 已开通微信云托管服务

## 第一步：开通微信云托管

### 1. 登录微信云托管控制台
1. 访问 [微信云托管控制台](https://cloud.weixin.qq.com/)
2. 使用微信开发者账号登录
3. 选择你的小程序项目

### 2. 开通云托管服务
1. 在控制台首页点击"开通云托管"
2. 选择"按量计费"或"包年包月"
3. 选择合适的地域（建议选择离用户最近的地域）
4. 确认开通

## 第二步：获取环境配置信息

### 1. 获取环境ID
1. 在云托管控制台找到"环境ID"
2. 复制环境ID（格式类似：`prod-xxxxxx`）

### 2. 获取数据库信息
1. 在云托管控制台创建MySQL数据库
2. 记录数据库连接信息：
   - 数据库地址
   - 端口（默认3306）
   - 数据库名
   - 用户名
   - 密码

## 第三步：更新项目配置

### 1. 更新 cloudbaserc.json
将以下配置中的占位符替换为实际值：

```json
{
  "envId": "你的实际环境ID",
  "version": "2.0",
  "$schema": "https://framework-1258016615.tcloudbaseapp.com/schema/latest.json",
  "functionRoot": "./functions",
  "functions": [],
  "framework": {
    "name": "tmc-map",
    "plugins": {
      "container": {
        "use": "@cloudbase/framework-plugin-container",
        "inputs": {
          "serviceName": "tmc-map-backend",
          "servicePath": "./tmc-map-backend",
          "uploadType": "image",
          "registryType": "tcr",
          "dockerfilePath": "./tmc-map-backend/Dockerfile",
          "buildDir": "./tmc-map-backend",
          "containerPort": 8080,
          "minNum": 0,
          "maxNum": 50,
          "cpu": 1,
          "mem": 2,
          "target": "container",
          "envVariables": {
            "SPRING_PROFILES_ACTIVE": "prod",
            "SERVER_PORT": "8080"
          },
          "customLogs": "stdout",
          "dataBaseName": "tmc_map",
          "vpc": {
            "vpcId": "",
            "subnetId": ""
          }
        }
      }
    }
  }
}
```

### 2. 更新数据库配置
编辑 `tmc-map-backend/src/main/resources/application-prod.yml`：

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://你的数据库地址:3306/tmc_map?useSSL=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8
    username: 你的数据库用户名
    password: 你的数据库密码
```

### 3. 移除不需要的API密钥配置
由于使用微信原生地图组件，可以移除以下配置：

```yaml
# 删除或注释掉这些配置
# tmc:
#   map:
#     api:
#       tencent:
#         key: your-production-tencent-map-api-key
#         base-url: https://apis.map.qq.com
#       amap:
#         key: your-production-amap-api-key
#         base-url: https://restapi.amap.com
```

## 第四步：安装云托管CLI工具

### 1. 安装Node.js
确保已安装Node.js 14+版本

### 2. 安装云托管CLI
```bash
npm install -g @cloudbase/cli
```

### 3. 登录云托管
```bash
tcb login
```

## 第五步：部署到云托管

### 1. 初始化数据库
1. 在云托管控制台创建数据库表
2. 或使用提供的SQL脚本初始化

### 2. 部署服务
```bash
# 在项目根目录执行
tcb framework deploy
```

### 3. 验证部署
1. 在云托管控制台查看服务状态
2. 测试API接口是否正常

## 第六步：配置域名和HTTPS

### 1. 配置自定义域名
1. 在云托管控制台配置自定义域名
2. 添加SSL证书（云托管自动提供）

### 2. 更新小程序配置
在小程序后台配置服务器域名：
- request合法域名：你的云托管域名
- socket合法域名：如果需要WebSocket

## 第七步：更新前端配置

### 1. 更新API地址
编辑 `uniapp-tmc-map/src/utils/request.js`：

```javascript
// 生产环境API地址
const BASE_URL = 'https://你的云托管域名/api'
```

### 2. 更新小程序配置
确保 `uniapp-tmc-map/src/manifest.json` 中的AppID正确：

```json
{
  "mp-weixin": {
    "appid": "你的小程序AppID"
  }
}
```

## 第八步：测试和监控

### 1. 功能测试
- 测试地图显示
- 测试俱乐部列表获取
- 测试位置服务
- 测试导航功能

### 2. 性能监控
- 在云托管控制台查看服务监控
- 监控CPU、内存使用情况
- 查看访问日志

## 常见问题解决

### 1. 部署失败
- 检查环境ID是否正确
- 确认数据库连接信息
- 查看构建日志

### 2. 数据库连接失败
- 确认数据库是否在云托管内网
- 检查数据库用户名密码
- 确认数据库端口开放

### 3. API调用失败
- 检查域名配置
- 确认HTTPS证书
- 查看网络请求日志

## 成本优化建议

### 1. 资源配置
- 根据实际访问量调整CPU和内存
- 设置合适的扩缩容策略

### 2. 数据库优化
- 使用连接池
- 优化SQL查询
- 添加适当的索引

### 3. 缓存策略
- 启用Redis缓存
- 合理设置缓存时间
- 使用CDN加速静态资源

## 安全配置

### 1. 网络安全
- 配置VPC网络隔离
- 设置安全组规则
- 启用WAF防护

### 2. 数据安全
- 数据库加密存储
- 敏感信息脱敏
- 定期备份数据

## 下一步

配置完成后，你可以：
1. 发布小程序到微信
2. 监控服务运行状态
3. 根据用户反馈优化功能
4. 扩展更多功能模块 