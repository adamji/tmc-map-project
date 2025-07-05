# 微信云托管配置文件模板

## 1. cloudbaserc.json 配置

请将以下配置中的占位符替换为实际值：

```json
{
  "envId": "你的环境ID",
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

## 2. application-prod.yml 配置

请将以下配置中的占位符替换为实际值：

```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  application:
    name: tmc-map-backend
  
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://你的数据库地址:3306/tmc_map?useSSL=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8
    username: 你的数据库用户名
    password: 你的数据库密码
    
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: GMT+8
    default-property-inclusion: non_null

# MyBatis Plus配置
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    cache-enabled: true
    call-setters-on-nulls: true
    jdbc-type-for-null: 'null'
    log-impl: org.apache.ibatis.logging.slf4j.Slf4jImpl
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0

# SpringDoc配置
springdoc:
  api-docs:
    enabled: false
  swagger-ui:
    enabled: false

# 日志配置
logging:
  level:
    com.tmcmap: info
    org.springframework.web: warn
    root: warn
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/tmc-map-backend.log

# 自定义配置
tmc:
  map:
    # 缓存配置
    cache:
      club-list-ttl: 3600 # 俱乐部列表缓存时间(秒)
      navigation-ttl: 1800 # 导航信息缓存时间(秒)
```

## 3. 前端API配置

更新 `uniapp-tmc-map/src/utils/request.js`：

```javascript
// 生产环境API地址
const BASE_URL = 'https://你的云托管域名/api'
```

## 4. 小程序配置

确保 `uniapp-tmc-map/src/manifest.json` 中的AppID正确：

```json
{
  "mp-weixin": {
    "appid": "你的小程序AppID"
  }
}
```

## 配置检查清单

- [ ] 环境ID已更新到 cloudbaserc.json
- [ ] 数据库连接信息已更新到 application-prod.yml
- [ ] 前端API地址已更新
- [ ] 小程序AppID已配置
- [ ] 云托管CLI已安装并登录
- [ ] 数据库已创建并初始化
- [ ] 域名已配置（可选）

## 部署命令

```bash
# 安装云托管CLI
npm install -g @cloudbase/cli

# 登录云托管
tcb login

# 部署服务
tcb framework deploy

# 查看部署状态
tcb framework list
```

## 测试命令

```bash
# 测试API接口
curl https://你的云托管域名/api/clubs

# 测试健康检查
curl https://你的云托管域名/api/health
``` 