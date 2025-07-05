# TMC Map Backend 本地部署指南

## 概述
由于Docker网络连接问题，本指南提供了不依赖Docker的本地部署方案。

## 前提条件
- Java 17 或更高版本
- Maven 3.6+
- 已构建的Spring Boot JAR包

## 部署方案

### 方案1: 交互式部署（推荐用于开发测试）
```bash
# 运行完整的构建和启动流程
./deploy-jar-local.bat
```

**功能：**
- 检查Java环境
- 自动构建Maven项目
- 启动Spring Boot应用
- 前台运行，可以看到实时日志
- 按Ctrl+C停止

### 方案2: 后台服务部署（推荐用于生产环境）
```bash
# 1. 首先构建项目（如果还没有构建）
cd tmc-map-backend
mvn clean package -DskipTests

# 2. 启动后台服务
./start-backend-service.bat

# 3. 停止服务
./stop-backend-service.bat
```

**功能：**
- 后台运行，不占用命令行窗口
- 自动生成日志文件
- 自动健康检查
- 提供停止脚本

## 配置说明

### 默认配置
- **端口**: 8080
- **配置文件**: application-prod.yml
- **内存设置**: 最小256MB，最大512MB
- **日志文件**: backend.log

### 自定义配置
修改脚本中的变量：
```batch
set SERVER_PORT=8080          # 服务端口
set SPRING_PROFILE=prod       # Spring配置文件
set JAVA_OPTS=-Xmx512m -Xms256m  # JVM内存设置
```

## 健康检查
服务启动后，访问健康检查端点：
```
http://localhost:8080/actuator/health
```

预期响应：
```json
{
  "status": "UP"
}
```

## API端点
- **健康检查**: `GET /actuator/health`
- **俱乐部列表**: `GET /api/clubs`
- **导航信息**: `GET /api/navigation`

## 故障排除

### 1. 端口被占用
```bash
# 查看端口占用
netstat -ano | findstr :8080

# 停止占用进程
taskkill /pid <PID> /f
```

### 2. Java版本问题
```bash
# 检查Java版本
java -version

# 应该显示Java 17或更高版本
```

### 3. 构建失败
```bash
# 清理并重新构建
cd tmc-map-backend
mvn clean
mvn package -DskipTests
```

### 4. 查看日志
- 前台运行：直接在命令行查看
- 后台运行：查看 `tmc-map-backend/backend.log`

## 生产环境建议

1. **使用Windows服务**
   - 使用NSSM或类似工具将Java应用注册为Windows服务
   - 设置自动启动和故障重启

2. **配置反向代理**
   - 使用Nginx或IIS作为反向代理
   - 配置SSL证书和域名

3. **监控和日志**
   - 配置日志轮转
   - 设置监控告警
   - 定期备份数据

4. **安全设置**
   - 配置防火墙规则
   - 使用非默认端口
   - 定期更新依赖

## 网络问题解决方案

如果Docker网络问题解决，可以回到Docker部署：
1. 重新配置Docker镜像源
2. 使用 `docker-compose.yml` 部署
3. 参考 `DOCKER_LOCAL_SETUP.md`

## 支持
遇到问题时，请检查：
1. Java版本和环境变量
2. 端口占用情况
3. 防火墙设置
4. 日志文件内容 