# Docker构建问题修复指南

## 🚨 问题分析

### 错误信息：
```
E: List directory /var/lib/apt/lists/partial is missing. - Acquire (13: Permission denied)
ERROR: failed to solve: process "/bin/sh -c apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*" did not complete successfully: exit code: 100
```

### 根本原因：
1. **权限问题**：在非root用户下执行apt-get命令
2. **用户切换时机**：在安装软件包之前就切换到了spring用户
3. **目录权限**：/var/lib/apt/lists/partial目录权限不足

## 🔧 修复方案

### 方案1：调整用户切换顺序（已修复）

**修复前的问题**：
```dockerfile
USER spring  # 过早切换到非root用户
RUN apt-get update  # 权限不足
```

**修复后的正确顺序**：
```dockerfile
# 创建用户
RUN groupadd -r spring && useradd -r -g spring spring

# 安装软件包（在root用户下）
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# 设置工作目录和文件
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
RUN mkdir -p /app/logs && chown -R spring:spring /app

# 最后切换到spring用户
USER spring
```

### 方案2：使用简化版Dockerfile

创建了 `Dockerfile.simple` 作为备用方案：
```dockerfile
# 使用官方镜像
FROM openjdk:17-jdk-slim

# 直接安装curl（默认root用户）
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# 不创建额外用户，简化权限管理
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
```

## 🚀 部署步骤

### 1. 本地测试
```bash
# 测试主要Dockerfile
docker build -t tmc-map-backend:main .

# 如果失败，测试简化版
docker build -f Dockerfile.simple -t tmc-map-backend:simple .
```

### 2. 运行测试脚本
```bash
# Windows
test-docker-build.bat

# 或手动测试
docker run --rm -d --name tmc-test -p 8080:8080 -e SPRING_PROFILES_ACTIVE=test tmc-map-backend:main
```

### 3. 云托管部署
如果主要Dockerfile仍有问题，可以：

1. **临时使用简化版**：
   - 将 `Dockerfile.simple` 重命名为 `Dockerfile`
   - 重新提交代码
   - 触发云托管构建

2. **配置环境变量**：
   ```bash
   SPRING_PROFILES_ACTIVE=prod
   DB_URL=jdbc:mysql://sh-cynosdbmysql-grp-7985lgv0.sql.tencentcdb.com:23824/tmc_map?useSSL=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8&allowPublicKeyRetrieval=true
   DB_USERNAME=root
   DB_PASSWORD=Zc2fQCTX
   ```

## 🔍 故障排除

### 如果构建仍然失败：

1. **检查基础镜像**：
   ```dockerfile
   # 尝试不同的基础镜像
   FROM openjdk:17-jdk-slim
   # 或
   FROM eclipse-temurin:17-jdk-alpine
   ```

2. **跳过curl安装**：
   ```dockerfile
   # 暂时注释掉curl安装和健康检查
   # RUN apt-get update && apt-get install -y curl
   # HEALTHCHECK ...
   ```

3. **使用预装curl的镜像**：
   ```dockerfile
   FROM openjdk:17-jdk  # 包含更多工具
   ```

### 权限问题解决方案：

1. **确保root权限**：
   ```dockerfile
   USER root
   RUN apt-get update
   USER spring
   ```

2. **使用sudo**：
   ```dockerfile
   RUN apt-get update && apt-get install -y sudo
   USER spring
   RUN sudo apt-get install -y curl
   ```

3. **简化权限管理**：
   ```dockerfile
   # 不创建额外用户，直接使用root
   WORKDIR /app
   COPY --from=builder /app/target/*.jar app.jar
   ```

## 📋 检查清单

部署前确认：
- [ ] Dockerfile语法正确
- [ ] 用户切换顺序正确
- [ ] 权限设置合理
- [ ] 本地构建成功
- [ ] 健康检查配置正确
- [ ] 环境变量配置完整

## 🎯 推荐配置

**生产环境推荐使用修复后的主要Dockerfile**：
- ✅ 安全性：使用非root用户运行
- ✅ 健康检查：多重检查机制
- ✅ 优化：JVM参数调优
- ✅ 日志：专用日志目录

**如果仍有问题，临时使用简化版**：
- ✅ 兼容性：减少权限问题
- ✅ 稳定性：简化构建过程
- ✅ 快速部署：减少构建时间

## 📞 技术支持

如果问题持续存在：
1. 查看完整的构建日志
2. 检查云托管环境的Docker版本
3. 尝试不同的基础镜像
4. 联系云托管技术支持 