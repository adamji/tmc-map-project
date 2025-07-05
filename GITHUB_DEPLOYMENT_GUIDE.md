# GitHub部署完整教程

## 第一步：将代码上传到GitHub

### 1.1 仓库结构建议

**推荐使用单仓库（Monorepo）结构**：
```
tmc-map-project/
├── backend/                 # Spring Boot后端
├── frontend/               # UniApp前端
├── docker-compose.yml      # 本地开发环境
├── .github/
│   └── workflows/         # GitHub Actions自动化部署
├── docs/                  # 文档目录
└── README.md
```

**优势**：
- 版本同步，API变更时前后端保持一致
- 部署协调，确保兼容性
- 代码管理统一，适合中小型项目

### 1.2 创建GitHub仓库

1. 登录GitHub，点击右上角 **"New repository"**
2. 填写仓库信息：
   - Repository name: `tmc-map-project`
   - Description: `TMC Map - WeChat Mini Program with Spring Boot Backend`
   - 选择 **Public** 或 **Private**
   - ✅ Add a README file
   - ✅ Add .gitignore (选择Java)
   - ✅ Choose a license (推荐MIT)

### 1.3 本地Git初始化

```bash
# 在项目根目录执行
git init
git remote add origin https://github.com/your-username/tmc-map-project.git

# 重新组织目录结构
mkdir backend frontend
mv tmc-map-backend/* backend/
mv uniapp-tmc-map/* frontend/
```

### 1.4 创建.gitignore文件

```gitignore
# Java
*.class
*.jar
*.war
*.ear
target/
.m2/
.settings/
.project
.classpath

# Node.js
node_modules/
npm-debug.log
yarn-error.log
.npm
.yarn/

# UniApp
unpackage/
dist/

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment files
.env
.env.local
.env.production
```

### 1.5 上传代码

```bash
# 添加所有文件
git add .

# 创建首次提交
git commit -m "Initial commit: TMC Map project with Spring Boot backend and UniApp frontend"

# 推送到GitHub
git push -u origin main
```

## 第二步：GitHub Actions + Docker云端部署

### 2.1 Docker配置

#### 后端Dockerfile优化

```dockerfile
# backend/Dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

# 复制Maven文件
COPY pom.xml .
COPY src ./src

# 安装Maven
RUN apt-get update && apt-get install -y maven

# 构建应用
RUN mvn clean package -DskipTests

# 运行应用
EXPOSE 8080
CMD ["java", "-jar", "target/tmc-map-backend-0.0.1-SNAPSHOT.jar"]
```

#### 前端Dockerfile

```dockerfile
# frontend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 构建项目
RUN npm run build:h5

# 使用nginx提供静态文件
FROM nginx:alpine
COPY --from=0 /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 2.2 GitHub Actions自动化部署

#### 创建部署工作流

```yaml
# .github/workflows/deploy.yml
name: Deploy to Docker Hub

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push backend
      uses: docker/build-push-action@v4
      with:
        context: ./backend
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/tmc-map-backend:latest
    
    - name: Build and push frontend
      uses: docker/build-push-action@v4
      with:
        context: ./frontend
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/tmc-map-frontend:latest
    
    - name: Deploy to server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.KEY }}
        script: |
          docker pull ${{ secrets.DOCKER_USERNAME }}/tmc-map-backend:latest
          docker pull ${{ secrets.DOCKER_USERNAME }}/tmc-map-frontend:latest
          docker-compose down
          docker-compose up -d
```

### 2.3 配置GitHub Secrets

在GitHub仓库设置中添加以下Secrets：

1. **Settings** → **Secrets and variables** → **Actions**
2. 添加以下secrets：
   - `DOCKER_USERNAME`: Docker Hub用户名
   - `DOCKER_PASSWORD`: Docker Hub密码
   - `HOST`: 服务器IP地址
   - `USERNAME`: 服务器用户名
   - `KEY`: 服务器SSH私钥

### 2.4 Docker Compose配置

```yaml
# docker-compose.yml
version: '3.8'

services:
  backend:
    image: your-username/tmc-map-backend:latest
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
    depends_on:
      - database
    networks:
      - tmc-network

  frontend:
    image: your-username/tmc-map-frontend:latest
    ports:
      - "80:80"
    networks:
      - tmc-network

  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: yourpassword
      MYSQL_DATABASE: tmc_map
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - tmc-network

volumes:
  mysql_data:

networks:
  tmc-network:
    driver: bridge
```

## 第三步：WeChat Cloud Hosting集成

### 3.1 云托管配置

```json
# cloudbaserc.json
{
  "envId": "your-env-id",
  "framework": {
    "name": "tmc-map",
    "plugins": {
      "container": {
        "use": "@cloudbase/framework-plugin-container",
        "inputs": {
          "serviceName": "tmc-map-backend",
          "servicePath": "/backend",
          "containerPort": 8080,
          "dockerfilePath": "./backend/Dockerfile",
          "buildDir": "./backend"
        }
      }
    }
  }
}
```

### 3.2 自动化部署脚本

```bash
# deploy-github-to-cloudbase.sh
#!/bin/bash

echo "=== TMC Map GitHub to WeChat Cloud Hosting Deployment ==="

# 1. 拉取最新代码
echo "Pulling latest code from GitHub..."
git pull origin main

# 2. 构建Docker镜像
echo "Building Docker images..."
docker build -t tmc-map-backend:latest ./backend
docker build -t tmc-map-frontend:latest ./frontend

# 3. 推送到云托管
echo "Deploying to WeChat Cloud Hosting..."
tcb login
tcb framework deploy

echo "Deployment completed successfully!"
```

## 第四步：部署验证

### 4.1 本地测试

```bash
# 启动本地环境
docker-compose up -d

# 检查服务状态
docker-compose ps

# 查看日志
docker-compose logs -f backend
```

### 4.2 生产环境验证

1. **后端API测试**：
   ```bash
   curl https://your-domain.com/api/clubs
   ```

2. **前端访问测试**：
   - 访问 `https://your-domain.com`
   - 检查微信小程序功能

3. **数据库连接测试**：
   ```bash
   docker exec -it mysql mysql -u root -p
   ```

## 常见问题解决

### Q1: Docker镜像构建失败
```bash
# 检查Dockerfile语法
docker build --no-cache -t test-image .

# 查看构建日志
docker build --progress=plain -t test-image .
```

### Q2: GitHub Actions部署失败
- 检查Secrets配置是否正确
- 查看Actions日志确定错误原因
- 验证Docker Hub权限

### Q3: 云托管连接失败
- 检查环境变量配置
- 确认端口映射正确
- 验证域名DNS解析

## 最佳实践建议

1. **分支管理**：
   - `main`: 生产环境
   - `develop`: 开发环境
   - `feature/*`: 功能分支

2. **版本管理**：
   - 使用语义化版本号
   - 每次发布创建Git Tag

3. **安全配置**：
   - 不要在代码中硬编码密码
   - 使用环境变量管理配置
   - 定期更新依赖包

4. **监控部署**：
   - 配置健康检查
   - 设置告警通知
   - 监控资源使用情况

这样你就完成了从GitHub到云端Docker的完整部署流程！ 