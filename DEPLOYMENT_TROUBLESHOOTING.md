# 部署问题排查指南

## 问题描述
Docker构建失败，错误信息：
```
E: Failed to fetch http://security.debian.org/debian-security/pool/updates/main/n/nghttp2/libnghttp2-14_1.43.0-1%2bdeb11u2_amd64.deb  Connection failed [IP: 151.101.66.132 80]
```

## 解决方案

### 方案1：使用简化版Dockerfile（推荐）
如果网络问题持续存在，使用 `Dockerfile.simple`：

```bash
docker build -f ./tmc-map-backend/Dockerfile.simple -t tmc-map-backend:latest ./tmc-map-backend
```

### 方案2：使用备用Dockerfile
如果主Dockerfile失败，使用 `Dockerfile.backup`：

```bash
docker build -f ./tmc-map-backend/Dockerfile.backup -t tmc-map-backend:latest ./tmc-map-backend
```

### 方案3：使用重试脚本
运行 `deploy-with-retry.bat` 脚本，它会自动重试并切换到备用方案。

### 方案4：手动修复网络问题
如果需要在Dockerfile中安装curl，可以尝试以下方法：

1. 使用国内镜像源：
```dockerfile
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

2. 添加重试机制：
```dockerfile
RUN for i in $(seq 1 3); do \
        apt-get update && \
        apt-get install -y --no-install-recommends curl && \
        break || sleep 5; \
    done && \
    rm -rf /var/lib/apt/lists/*
```

## 验证部署

### 1. 本地测试
```bash
# 构建镜像
docker build -f ./tmc-map-backend/Dockerfile.simple -t tmc-map-backend:latest ./tmc-map-backend

# 运行容器
docker run -p 8080:8080 tmc-map-backend:latest

# 测试健康检查
curl http://localhost:8080/api/actuator/health
```

### 2. 推送到云托管
```bash
# 登录到腾讯云容器镜像服务
docker login ccr.ccs.tencentyun.com

# 标记镜像
docker tag tmc-map-backend:latest [你的镜像仓库地址]:latest

# 推送镜像
docker push [你的镜像仓库地址]:latest
```

## 常见问题

### Q: 为什么会出现网络连接失败？
A: 这通常是由于：
- 网络不稳定
- 防火墙阻止
- DNS解析问题
- 镜像源服务器暂时不可用

### Q: 不使用curl会影响应用吗？
A: 不会。curl主要用于健康检查，我们可以：
- 使用进程检查替代HTTP检查
- 在应用内部实现健康检查端点
- 使用其他监控方式

### Q: 如何确保应用正常运行？
A: 可以通过以下方式验证：
- 检查应用日志
- 访问API端点
- 使用Spring Boot Actuator的健康检查
- 监控JVM进程状态

## 最佳实践

1. **优先使用简化版Dockerfile**：避免不必要的网络依赖
2. **添加重试机制**：处理临时网络问题
3. **使用多阶段构建**：减少最终镜像大小
4. **配置健康检查**：确保应用状态可监控
5. **使用非root用户**：提高安全性 