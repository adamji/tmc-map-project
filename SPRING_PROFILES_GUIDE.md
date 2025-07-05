# Spring Boot 配置文件使用指南

## 配置文件结构
```
src/main/resources/
├── application.yml          # 主配置文件，默认使用prod配置
├── application-dev.yml      # 开发环境配置（H2内存数据库）
└── application-prod.yml     # 生产环境配置（MySQL数据库）
```

## 配置优先级说明

### 1. 默认配置
- **主配置文件**: `application.yml` 
- **默认Profile**: `prod`
- **目的**: 确保生产环境部署时使用正确的数据库配置

### 2. 环境配置覆盖
不同环境下，配置会按以下优先级被覆盖：

1. **命令行参数** (最高优先级)
2. **环境变量**
3. **application-{profile}.yml**
4. **application.yml** (最低优先级)

## 不同环境的使用方式

### 微信云托管 (生产环境)
```yaml
# 自动使用application.yml中的默认配置
spring:
  profiles:
    active: prod
```
- 使用MySQL数据库
- 连接云数据库实例
- 优化的日志配置

### 本地开发环境
有三种方式指定使用dev配置：

#### 方式1: 命令行参数
```bash
java -jar app.jar --spring.profiles.active=dev
```

#### 方式2: 环境变量
```bash
export SPRING_PROFILES_ACTIVE=dev
java -jar app.jar
```

#### 方式3: IDE配置
在IDE中设置VM参数：
```
-Dspring.profiles.active=dev
```

### Docker本地测试
```bash
# 使用dev配置
docker run -e SPRING_PROFILES_ACTIVE=dev your-image

# 使用prod配置（默认）
docker run your-image
```

## 配置文件内容对比

### Dev环境 (application-dev.yml)
```yaml
spring:
  datasource:
    driver-class-name: org.h2.Driver
    url: jdbc:h2:mem:tmc_map
    username: sa
    password: 
  h2:
    console:
      enabled: true  # 启用H2控制台
logging:
  level:
    com.tmcmap: debug  # 详细日志
```

### Prod环境 (application-prod.yml)
```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://10.22.100.35:3306/tmc_map
    username: root
    password: Zc2fQCTX
logging:
  level:
    com.tmcmap: info   # 生产级别日志
```

## 本地开发脚本更新

### 开发环境脚本
```batch
REM deploy-jar-local.bat 已更新为使用dev配置
set SPRING_PROFILE=dev
java -Dspring.profiles.active=%SPRING_PROFILE% -jar target/app.jar
```

### 生产环境测试脚本
```batch
REM 测试生产配置（需要MySQL数据库）
set SPRING_PROFILE=prod
java -Dspring.profiles.active=%SPRING_PROFILE% -jar target/app.jar
```

## 验证配置生效

### 1. 检查启动日志
```
The following 1 profile is active: "prod"
```

### 2. 检查数据库连接
- **Dev**: 访问 `http://localhost:8080/h2-console`
- **Prod**: 检查MySQL连接日志

### 3. 健康检查端点
```bash
curl http://localhost:8080/actuator/health
```

## 故障排除

### 问题1: 云托管使用了错误的配置
**原因**: `application.yml` 中默认profile设置错误
**解决**: 确保 `spring.profiles.active: prod`

### 问题2: 本地开发连接生产数据库
**原因**: 没有正确指定dev profile
**解决**: 使用 `-Dspring.profiles.active=dev` 参数

### 问题3: Docker构建时配置错误
**原因**: Dockerfile中硬编码了profile
**解决**: 使用环境变量传递profile配置

## 最佳实践

1. **生产优先**: 默认配置应该是生产环境安全的
2. **环境隔离**: 不同环境使用不同的数据库
3. **敏感信息**: 生产环境密码通过环境变量传递
4. **配置验证**: 部署前验证配置文件正确性

## 环境变量配置 (推荐)

对于生产环境，建议使用环境变量覆盖敏感配置：

```bash
# 微信云托管环境变量配置
SPRING_DATASOURCE_URL=jdbc:mysql://your-db-host:3306/tmc_map
SPRING_DATASOURCE_USERNAME=your-username
SPRING_DATASOURCE_PASSWORD=your-password
```

这样可以避免在代码中硬编码敏感信息。 