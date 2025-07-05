# 微信云托管自带数据库配置指南

## 概述
微信云托管提供了内置的MySQL数据库服务，无需额外配置，可以直接使用。

## 第一步：在云托管控制台创建数据库

### 1. 登录云托管控制台
1. 访问 [微信云托管控制台](https://cloud.weixin.qq.com/)
2. 选择你的环境
3. 进入"数据库"页面

### 2. 创建MySQL数据库
1. 点击"新建数据库"
2. 选择"MySQL"
3. 配置数据库信息：
   - 数据库名：`tmc_map`
   - 用户名：`tmc_user`（或自定义）
   - 密码：设置一个强密码
   - 端口：3306（默认）
4. 点击"确定"创建

### 3. 获取数据库连接信息
创建完成后，你会得到：
- 数据库地址：通常是内网地址，如 `mysql-xxxxx.service.tcloudbaseapp.com`
- 端口：3306
- 数据库名：tmc_map
- 用户名：你设置的用户名
- 密码：你设置的密码

## 第二步：更新项目配置

### 1. 更新 cloudbaserc.json
确保配置中包含数据库信息：

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

### 2. 更新 application-prod.yml
将数据库连接信息更新为云托管数据库：

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
    url: jdbc:mysql://你的云托管数据库地址:3306/tmc_map?useSSL=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8&allowPublicKeyRetrieval=true
    username: 你的数据库用户名
    password: 你的数据库密码
    
  jpa:
    hibernate:
      ddl-auto: update  # 自动创建表结构
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

## 第三步：初始化数据库表结构

### 方法1：使用JPA自动创建（推荐）
设置 `ddl-auto: update`，Spring Boot会自动创建表结构。

### 方法2：手动执行SQL脚本
如果需要手动初始化数据，可以在云托管控制台的数据库管理页面执行SQL：

```sql
-- 创建俱乐部表
CREATE TABLE IF NOT EXISTS club (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL COMMENT '俱乐部名称',
    short_name VARCHAR(100) COMMENT '简称',
    address VARCHAR(500) COMMENT '地址',
    lat DECIMAL(10, 8) COMMENT '纬度',
    lng DECIMAL(11, 8) COMMENT '经度',
    city VARCHAR(50) COMMENT '城市',
    meeting_time VARCHAR(100) COMMENT '会议时间',
    language VARCHAR(50) COMMENT '语言',
    contact VARCHAR(100) COMMENT '联系人',
    phone VARCHAR(20) COMMENT '联系电话',
    features TEXT COMMENT '特色',
    description TEXT COMMENT '描述',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0 COMMENT '删除标记'
);

-- 插入示例数据
INSERT INTO club (name, short_name, address, lat, lng, city, meeting_time, language, contact, phone, features, description) VALUES
('南京江宁国际演讲俱乐部', '江宁TMC', '南京市江宁经济技术开发区双龙大道1539号21世纪太阳城', 31.9558, 118.8420, '南京', '周五 19:30-21:30 双语', '双语', 'Sarah CHEN', '15850123456', '21世纪太阳城，购物便利', '大学生和年轻职场人士首选'),
('南京鼓楼国际演讲俱乐部', '鼓楼TMC', '南京市鼓楼区中山路321号现代大厦', 32.0584, 118.7964, '南京', '周三 19:00-21:00 中文', '中文', 'Mike WANG', '13987654321', '市中心位置，交通便利', '职场精英交流平台');
```

## 第四步：部署和测试

### 1. 部署服务
```bash
# 安装云托管CLI
npm install -g @cloudbase/cli

# 登录云托管
tcb login

# 部署服务
tcb framework deploy
```

### 2. 验证数据库连接
部署完成后，检查服务日志确认数据库连接正常：

```bash
# 查看服务日志
tcb framework logs

# 测试API接口
curl https://你的云托管域名/api/clubs
```

## 第五步：数据库管理

### 1. 在云托管控制台管理数据库
- 查看数据库状态
- 执行SQL查询
- 备份和恢复数据
- 监控数据库性能

### 2. 数据库连接池配置
可以在 `application-prod.yml` 中添加连接池配置：

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

## 优势

使用云托管自带数据库的优势：
1. **无需额外配置**：数据库与容器服务在同一VPC内
2. **自动备份**：云托管提供自动备份功能
3. **监控完善**：提供详细的数据库监控指标
4. **成本优化**：按实际使用量计费
5. **安全可靠**：内置安全防护和访问控制

## 注意事项

1. **网络连接**：云托管数据库只能通过内网访问，确保容器服务在同一VPC
2. **密码安全**：使用强密码，定期更换
3. **备份策略**：定期备份重要数据
4. **性能监控**：关注数据库性能指标，及时优化

## 故障排除

### 1. 数据库连接失败
- 检查数据库地址是否正确
- 确认用户名密码
- 检查网络连接

### 2. 表结构问题
- 检查JPA配置
- 查看启动日志
- 手动执行SQL创建表

### 3. 性能问题
- 优化SQL查询
- 调整连接池配置
- 添加数据库索引 