# Docker环境配置指南

## 安装Docker
```bash
# CentOS/RHEL
yum install -y docker
systemctl start docker
systemctl enable docker

# Ubuntu/Debian  
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# 验证安装
docker --version
```

## 安装Docker Compose
```bash
# 下载Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 设置执行权限
chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

## 安装腾讯云CLI (可选)
```bash
# 安装tcb CLI
npm install -g @cloudbase/cli

# 登录
tcb login
``` 