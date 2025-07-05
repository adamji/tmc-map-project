# 🐳 本地Docker测试环境设置指南

## 📋 前提条件

- Windows 10/11 (64位)
- 至少4GB RAM
- 启用虚拟化技术(BIOS中的VT-x/AMD-V)

## 🚀 第一步：安装Docker Desktop

### 1. 下载Docker Desktop
- 访问: https://www.docker.com/products/docker-desktop/
- 点击 "Download for Windows"
- 下载 `Docker Desktop Installer.exe`

### 2. 安装Docker Desktop
- 双击运行下载的安装文件
- 按照安装向导完成安装
- 安装完成后重启电脑

### 3. 启动Docker Desktop
- 重启后，Docker Desktop会自动启动
- 等待Docker引擎完全启动（托盘图标变为绿色）

## 🔧 第二步：验证安装

打开PowerShell或命令提示符，运行以下命令：

```bash
# 检查Docker版本
docker --version

# 检查Docker Compose版本
docker-compose --version

# 运行测试容器
docker run hello-world
```

## 🏗️ 第三步：构建本地Docker镜像

### 1. 构建后端镜像
```bash
# 进入后端目录
cd tmc-map-backend

# 构建Docker镜像
docker build -t tmc-map-backend:local .

# 查看构建的镜像
docker images
```

### 2. 构建前端镜像
```bash
# 进入前端目录
cd ../uniapp-tmc-map

# 构建Docker镜像
docker build -t tmc-map-frontend:local .

# 查看构建的镜像
docker images
```

## 🚀 第四步：使用Docker Compose启动完整环境

### 1. 启动所有服务
```bash
# 回到项目根目录
cd ..

# 启动所有服务
docker-compose up -d

# 查看运行状态
docker-compose ps
```

### 2. 查看服务日志
```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务日志
docker-compose logs backend
docker-compose logs frontend
docker-compose logs database
```

### 3. 访问服务
- **后端API**: http://localhost:8080
- **前端页面**: http://localhost:80
- **数据库**: localhost:3306

## 🧪 第五步：测试功能

### 1. 测试后端API
```bash
# 测试健康检查
curl http://localhost:8080/actuator/health

# 测试俱乐部API
curl http://localhost:8080/api/clubs
```

### 2. 测试前端页面
- 打开浏览器访问: http://localhost:80
- 检查页面是否正常加载
- 测试地图功能

### 3. 测试数据库连接
```bash
# 连接到MySQL容器
docker exec -it tmc-map-family-database-1 mysql -u root -p

# 输入密码: yourpassword
# 查看数据库
SHOW DATABASES;
USE tmc_map;
SHOW TABLES;
```

## 🔍 第六步：故障排除

### 常见问题解决

#### 1. Docker Desktop启动失败
- 检查Windows虚拟化是否启用
- 重启Docker Desktop
- 检查防火墙设置

#### 2. 端口被占用
```bash
# 查看端口占用
netstat -ano | findstr :8080
netstat -ano | findstr :80

# 停止占用端口的进程
taskkill /PID [进程ID] /F
```

#### 3. 镜像构建失败
```bash
# 清理Docker缓存
docker system prune -a

# 重新构建镜像
docker build --no-cache -t tmc-map-backend:local .
```

#### 4. 容器启动失败
```bash
# 查看容器日志
docker-compose logs [服务名]

# 重启服务
docker-compose restart [服务名]

# 重新创建容器
docker-compose up -d --force-recreate
```

## 📊 第七步：性能监控

### 查看资源使用情况
```bash
# 查看容器资源使用
docker stats

# 查看磁盘使用
docker system df

# 查看网络
docker network ls
```

## 🧹 第八步：清理环境

### 停止和清理
```bash
# 停止所有服务
docker-compose down

# 删除所有容器
docker container prune

# 删除所有镜像
docker image prune -a

# 清理所有Docker资源
docker system prune -a
```

## 🎯 快速测试脚本

我为你创建了一个自动化测试脚本：

```bash
# 运行完整测试
./test-docker-local.bat
```

## 📝 测试检查清单

- [ ] Docker Desktop安装并运行
- [ ] 后端镜像构建成功
- [ ] 前端镜像构建成功
- [ ] 所有服务启动成功
- [ ] 后端API可访问
- [ ] 前端页面可访问
- [ ] 数据库连接正常
- [ ] 功能测试通过

## 🎉 成功标志

当你看到以下输出时，说明本地Docker测试环境设置成功：

```
✅ Docker Desktop运行正常
✅ 所有镜像构建成功
✅ 所有服务启动成功
✅ 后端API: http://localhost:8080 ✅
✅ 前端页面: http://localhost:80 ✅
✅ 数据库: localhost:3306 ✅
```

现在你可以在本地完全测试你的TMC Map项目了！🚀 