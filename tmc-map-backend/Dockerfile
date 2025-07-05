# ---------- 构建阶段 ----------
FROM maven:3.8.4-openjdk-17 AS builder

WORKDIR /app

# 只复制依赖文件，利用缓存加速构建
COPY pom.xml .
COPY src ./src

# 下载依赖并打包（跳过测试）
RUN mvn clean package -DskipTests

# ---------- 运行阶段 ----------
# 使用更通用的基础镜像，兼容国内外环境
FROM eclipse-temurin:17-jdk-jammy

# 创建非root用户，提升安全性
RUN groupadd -r spring && useradd -r -g spring spring

# 安装curl用于健康检查
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制jar包
COPY --from=builder /app/target/*.jar app.jar

# 创建日志目录并赋权
RUN mkdir -p /app/logs && chown -R spring:spring /app

# 切换到spring用户
USER spring

EXPOSE 8080

# 健康检查配置 - 多种检查方式
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:8080/api/actuator/health || \
      curl -f http://localhost:8080/api/health || \
      curl -f http://localhost:8080/api/ || exit 1

# JVM参数优化 - 加快启动速度，减少内存占用
ENV JAVA_OPTS="-Xms256m -Xmx1024m -XX:+UseG1GC -XX:+UseStringDeduplication -Djava.security.egd=file:/dev/./urandom -XX:TieredStopAtLevel=1 -XX:+UseContainerSupport"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 