# 🚀 TMC地图小程序详细部署指南

## 📋 总览

本指南将逐步教你如何部署TMC地图小程序，包含前端和后端的完整架构。

## 🎯 部署顺序

1. **服务器准备** (第1天)
2. **小程序账号申请** (第1天)
3. **地图API申请** (第1天)
4. **后端部署** (第2天)
5. **前端配置与发布** (第3天)

---

## 1️⃣ 服务器准备 (最关键步骤)

### 🖥️ 云服务器选择与购买

#### 腾讯云 (推荐)
**网站**: https://cloud.tencent.com/

**步骤**:
1. **注册账号**
   - 访问 https://cloud.tencent.com/
   - 点击右上角"注册"
   - 使用微信扫码注册 (新用户有优惠)
   - 完成实名认证

2. **选择服务器**
   - 进入控制台: https://console.cloud.tencent.com/
   - 点击"云服务器 CVM"
   - 选择"立即购买"

3. **配置选择**
   ```
   地域: 选择距离用户最近的 (如深圳、上海、北京)
   机型: 标准型 S5
   CPU: 2核
   内存: 4GB
   系统盘: 系统盘 SSD云硬盘 50GB
   公网带宽: 按流量计费, 带宽峰值 5Mbps
   操作系统: CentOS 7.6 64位 或 Ubuntu 20.04 LTS
   购买时长: 1年 (年付有折扣)
   ```

4. **购买链接**
   - 新用户活动: https://cloud.tencent.com/act/cps/redirect?redirect=1040&cps_key=your_key
   - 预估费用: ¥99-156/年

#### 阿里云 (备选)
**网站**: https://www.aliyun.com/

**步骤**:
1. **注册账号**
   - 访问 https://www.aliyun.com/
   - 点击"免费注册"
   - 完成实名认证

2. **选择ECS云服务器**
   - 进入控制台: https://ecs.console.aliyun.com/
   - 选择"创建实例"

3. **配置推荐**
   ```
   地域: 华东1(杭州) 或 华南1(深圳)
   实例规格: ecs.t5-lc1m2.small (1核2GB) 或 ecs.c5.large (2核4GB)
   镜像: CentOS 7.9 64位
   网络: 专有网络VPC
   公网IP: 分配公网IPv4地址
   带宽: 按使用流量, 峰值带宽5M
   ```

4. **购买链接**
   - 新用户优惠: https://www.aliyun.com/minisite/goods?userCode=your_code
   - 预估费用: ¥85-150/年

### 🌐 域名购买与配置

#### 1. 域名购买
**推荐网站**: 
- 腾讯云: https://dnspod.cloud.tencent.com/
- 阿里云: https://wanwang.aliyun.com/
- GoDaddy: https://www.godaddy.com/ (国际域名)

**步骤**:
1. 搜索域名 `tmcmap.com` 或 `your-project-name.com`
2. 选择 `.com` 后缀 (推荐)
3. 购买1年 (价格: ¥55-80/年)

#### 2. 域名解析配置
**腾讯云DNS配置**:
1. 进入 https://console.cloud.tencent.com/cns
2. 添加域名
3. 添加解析记录:
   ```
   记录类型: A
   主机记录: api
   记录值: 你的服务器公网IP
   TTL: 600
   ```
4. 最终解析: `api.tmcmap.com` → 你的服务器IP

### 🔒 SSL证书申请

#### 方式1: Let's Encrypt (免费推荐)
**网站**: https://letsencrypt.org/

**在服务器上执行**:
```bash
# 安装certbot
sudo yum install certbot python3-certbot-nginx  # CentOS
# 或
sudo apt install certbot python3-certbot-nginx  # Ubuntu

# 申请证书
sudo certbot --nginx -d api.tmcmap.com

# 自动续期
sudo crontab -e
# 添加: 0 12 * * * /usr/bin/certbot renew --quiet
```

#### 方式2: 云服务商SSL (付费)
**腾讯云SSL**:
1. 访问 https://console.cloud.tencent.com/ssl
2. 选择"申请免费证书" 或购买付费证书
3. 验证域名所有权
4. 下载证书并配置到Nginx

---

## 2️⃣ 微信小程序账号申请

### 📱 注册小程序账号

**网站**: https://mp.weixin.qq.com/

**详细步骤**:

1. **访问注册页面**
   - 打开 https://mp.weixin.qq.com/
   - 点击右上角"立即注册"
   - 选择"小程序"

2. **填写注册信息**
   ```
   邮箱: 使用未注册过微信的邮箱
   密码: 设置强密码
   ```

3. **邮箱验证**
   - 查收邮件并点击确认链接

4. **选择主体类型**
   - **个人**: 适合个人开发者，功能有限制
   - **企业**: 需要营业执照，功能完整
   - **政府**: 需要政府机构证明
   - **其他组织**: 需要组织机构代码证

5. **身份认证**
   
   **个人认证**:
   - 管理员身份证号码
   - 管理员手机号
   - 微信扫码验证

   **企业认证**:
   - 企业名称
   - 营业执照注册号
   - 对公账户信息
   - 认证费用: ¥300/年

6. **获取AppID**
   - 认证通过后，在"开发管理" → "开发设置"中找到AppID
   - 记录AppID，后面配置时需要

### 🔧 小程序后台配置

**配置步骤**:

1. **登录小程序后台**
   - https://mp.weixin.qq.com/
   - 使用注册时的邮箱登录

2. **配置服务器域名**
   - 进入"开发" → "开发管理" → "开发设置"
   - 在"服务器域名"部分添加:
   ```
   request合法域名:
   - https://api.tmcmap.com
   - https://apis.map.qq.com
   
   downloadFile合法域名:
   - https://rt0.map.gtimg.com
   - https://rt1.map.gtimg.com
   - https://rt2.map.gtimg.com
   - https://rt3.map.gtimg.com
   ```

3. **配置业务域名**
   - 如果需要跳转到H5页面，在"业务域名"中添加相应域名

---

## 3️⃣ 腾讯地图API申请

### 🗺️ 申请开发者账号

**网站**: https://lbs.qq.com/

**步骤**:

1. **注册账号**
   - 访问 https://lbs.qq.com/
   - 点击右上角"控制台"
   - 使用QQ账号登录

2. **完成开发者认证**
   - 进入控制台: https://lbs.qq.com/console/
   - 点击"个人中心" → "认证信息"
   - 填写个人或企业信息

3. **创建应用**
   - 在控制台中点击"应用管理" → "我的应用"
   - 点击"创建应用"
   ```
   应用名称: TMC俱乐部地图
   应用类型: 微信小程序
   应用描述: 头马俱乐部地图小程序
   ```

4. **获取API Key**
   - 创建成功后，记录分配的Key
   - 在"配置"中设置调用限制和白名单

5. **配置额度**
   ```
   免费额度 (个人):
   - 基础LBS服务: 15万次/月
   - 地图显示: 150万次/月
   - 搜索服务: 5000次/月
   
   免费额度 (企业):
   - 基础LBS服务: 300万次/月
   - 地图显示: 3000万次/月
   - 搜索服务: 5万次/月
   ```

---

## 4️⃣ 后端部署

### 💾 数据库安装与配置

#### MySQL安装 (CentOS 7)
```bash
# 1. 下载MySQL Yum Repository
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

# 2. 安装repository
sudo rpm -Uvh mysql80-community-release-el7-3.noarch.rpm

# 3. 安装MySQL
sudo yum install mysql-community-server

# 4. 启动MySQL
sudo systemctl start mysqld
sudo systemctl enable mysqld

# 5. 获取临时密码
sudo grep 'temporary password' /var/log/mysqld.log

# 6. 安全配置
sudo mysql_secure_installation
```

#### MySQL安装 (Ubuntu 20.04)
```bash
# 1. 更新包列表
sudo apt update

# 2. 安装MySQL
sudo apt install mysql-server

# 3. 安全配置
sudo mysql_secure_installation

# 4. 启动服务
sudo systemctl start mysql
sudo systemctl enable mysql
```

#### 数据库初始化
```bash
# 1. 登录MySQL
mysql -u root -p

# 2. 创建数据库和用户
CREATE DATABASE tmc_map CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'tmcmap'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';
GRANT ALL PRIVILEGES ON tmc_map.* TO 'tmcmap'@'localhost';
FLUSH PRIVILEGES;

# 3. 执行初始化脚本
USE tmc_map;
source /path/to/your/production-init.sql;
```

### ☕ Java环境安装

#### Java 17安装
```bash
# CentOS 7
sudo yum install java-17-openjdk java-17-openjdk-devel

# Ubuntu 20.04
sudo apt install openjdk-17-jdk

# 验证安装
java -version
javac -version
```

### 🔧 后端应用部署

#### 1. 上传应用
```bash
# 在本地构建
cd tmc-map-backend
mvn clean package -Pprod

# 上传到服务器
scp target/tmc-map-backend-1.0.0.jar root@your-server-ip:/opt/tmcmap/
```

#### 2. 配置生产环境
```bash
# 创建目录
sudo mkdir -p /opt/tmcmap/logs
sudo mkdir -p /opt/tmcmap/config

# 创建配置文件
sudo nano /opt/tmcmap/config/application-prod.yml
```

配置内容:
```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/tmc_map?useSSL=true&serverTimezone=Asia/Shanghai
    username: tmcmap
    password: YourStrongPassword123!
    driver-class-name: com.mysql.cj.jdbc.Driver

tmc:
  map:
    api:
      tencent:
        key: YOUR_TENCENT_MAP_API_KEY
```

#### 3. 创建系统服务
```bash
sudo nano /etc/systemd/system/tmcmap.service
```

服务配置:
```ini
[Unit]
Description=TMC Map Backend Service
After=network.target

[Service]
Type=simple
User=tmcmap
WorkingDirectory=/opt/tmcmap
ExecStart=/usr/bin/java -jar -Dspring.profiles.active=prod /opt/tmcmap/tmc-map-backend-1.0.0.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

#### 4. 启动服务
```bash
# 创建用户
sudo useradd -r tmcmap

# 设置权限
sudo chown -R tmcmap:tmcmap /opt/tmcmap

# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable tmcmap
sudo systemctl start tmcmap

# 检查状态
sudo systemctl status tmcmap
```

### 🌐 Nginx配置

#### 安装Nginx
```bash
# CentOS 7
sudo yum install nginx

# Ubuntu 20.04
sudo apt install nginx
```

#### 配置反向代理
```bash
sudo nano /etc/nginx/sites-available/tmcmap
```

Nginx配置:
```nginx
server {
    listen 80;
    server_name api.tmcmap.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.tmcmap.com;

    ssl_certificate /etc/letsencrypt/live/api.tmcmap.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.tmcmap.com/privkey.pem;

    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

启用配置:
```bash
sudo ln -s /etc/nginx/sites-available/tmcmap /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## 5️⃣ 前端配置与发布

### 🔧 更新配置文件

#### 1. 更新manifest.json
```json
{
  "mp-weixin": {
    "appid": "wx7fb77d9708797ce0"  // 替换为你的真实AppID
  }
}
```

#### 2. 确认API地址
检查 `src/services/club.js` 中的生产环境URL:
```javascript
// 生产环境
return 'https://api.tmcmap.com'
```

### 📱 小程序发布

#### 1. 安装微信开发者工具
**下载地址**: https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html

#### 2. 导入项目
```bash
# 构建项目
cd uniapp-tmc-map
npm install
npm run build:mp-weixin
```

#### 3. 上传发布
1. 用微信开发者工具打开 `dist/dev/mp-weixin` 目录
2. 点击"上传"按钮
3. 填写版本号和项目备注

#### 4. 提交审核
1. 登录 https://mp.weixin.qq.com/
2. 在"版本管理"中找到刚上传的版本
3. 点击"提交审核"
4. 填写审核信息

---

## 📊 验证与测试

### 🔍 后端验证
```bash
# 测试API接口
curl https://api.tmcmap.com/api/clubs

# 检查服务状态
sudo systemctl status tmcmap

# 查看日志
sudo journalctl -u tmcmap -f
```

### 📱 前端验证
1. 在微信开发者工具中预览
2. 扫码在手机上测试
3. 检查所有功能是否正常

---

## 💰 总成本预估

| 项目 | 费用 | 说明 |
|------|------|------|
| 云服务器 | ¥99-156/年 | 腾讯云新用户优惠 |
| 域名 | ¥55-80/年 | .com域名 |
| SSL证书 | ¥0 | Let's Encrypt免费 |
| 小程序账号 | ¥300/年 | 企业认证 |
| 地图API | ¥0 | 免费额度内 |
| **总计** | **¥454-636/年** | **约¥38-53/月** |

---

## 🚨 常见问题解决

### 1. 服务器连接不上
```bash
# 检查防火墙
sudo systemctl status firewalld
sudo firewall-cmd --list-all

# 开放端口
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### 2. 域名解析不生效
- 等待DNS传播 (通常2-24小时)
- 使用DNS检测工具: https://www.whatsmydns.net/

### 3. SSL证书问题
```bash
# 重新申请证书
sudo certbot delete --cert-name api.tmcmap.com
sudo certbot --nginx -d api.tmcmap.com
```

### 4. 小程序审核被拒
- 检查功能描述是否准确
- 提供详细的使用说明
- 确保符合微信小程序规范

---

**预计完成时间**: 2-3天
**技术支持**: 遇到问题可参考各平台官方文档或寻求技术支持 