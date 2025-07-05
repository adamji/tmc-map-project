# 🚀 头马俱乐部地图小程序上线快速检查清单

## 🔥 立即需要完成的任务

### 1. 服务器准备 (最高优先级)
- [ ] **申请云服务器** (推荐阿里云/腾讯云)
- [ ] **购买域名** api.tmcmap.com 并配置DNS解析
- [ ] **申请SSL证书** (Let's Encrypt 或云服务商提供)
- [ ] **安装环境**: Java 17+ + MySQL 8.0+

### 2. 小程序账号申请 (高优先级)
- [ ] **注册微信小程序账号** → https://mp.weixin.qq.com
- [ ] **完成账号认证** (需要营业执照或个人认证)
- [ ] **获取AppID** 并更新到 `manifest.json`

### 3. 地图API密钥申请 (高优先级)
- [ ] **申请腾讯地图API密钥** → https://lbs.qq.com/
- [ ] **配置密钥到** `application-prod.yml`
- [ ] **测试API密钥** 是否可用

## 📋 配置更新任务

### 文件更新清单
- [ ] `manifest.json` → 更新真实AppID
- [ ] `application-prod.yml` → 数据库连接信息
- [ ] `application-prod.yml` → 腾讯地图API密钥
- [ ] `club.js` → 确认生产环境API地址

### 微信小程序后台配置
- [ ] **服务器域名白名单**:
  - `https://api.tmcmap.com`
  - `https://apis.map.qq.com`
  - `https://rt0.map.gtimg.com`
  - `https://rt1.map.gtimg.com`
  - `https://rt2.map.gtimg.com`
  - `https://rt3.map.gtimg.com`

## 🎯 部署流程

### 后端部署
```bash
# 1. 数据库初始化
mysql -u root -p < tmc-map-backend/src/main/resources/sql/production-init.sql

# 2. 构建项目
cd tmc-map-backend
mvn clean package -Pprod

# 3. 部署到服务器
java -jar -Dspring.profiles.active=prod target/tmc-map-backend-1.0.0.jar
```

### 前端部署
```bash
# 1. 构建小程序
cd uniapp-tmc-map
npm install
npm run build:mp-weixin

# 2. 使用微信开发者工具导入dist/dev/mp-weixin
# 3. 点击"上传"提交代码
# 4. 在微信公众平台提交审核
```

## ⚡ 关键验证点

### 后端验证
- [ ] `curl https://api.tmcmap.com/api/clubs` 返回俱乐部列表
- [ ] 数据库连接正常
- [ ] 日志文件正常生成

### 前端验证
- [ ] 微信开发者工具中小程序正常预览
- [ ] 地图显示正常
- [ ] 俱乐部标记显示
- [ ] 筛选功能正常
- [ ] 导航功能正常

## 🚨 常见问题快速解决

### 问题1: 服务器域名未配置
**现象**: 小程序请求失败，显示"不在域名白名单中"
**解决**: 在微信小程序后台添加域名白名单

### 问题2: 地图不显示
**现象**: 地图组件空白或报错
**解决**: 检查腾讯地图API密钥是否正确配置

### 问题3: 数据库连接失败
**现象**: 后端启动报错或API返回500
**解决**: 检查MySQL连接信息和数据库是否正确初始化

### 问题4: HTTPS证书问题
**现象**: API请求失败，显示证书错误
**解决**: 确认SSL证书正确配置，可使用Let's Encrypt

## 📞 上线后监控

### 必须监控的指标
- [ ] 服务器CPU/内存使用率
- [ ] 数据库连接数
- [ ] API响应时间
- [ ] 小程序用户访问数据

### 日志文件位置
- 后端日志: `/opt/tmcmap/logs/tmc-map-backend.log`
- 系统日志: `/var/log/`

---

**预计完成时间**: 2-3天（包括审核时间）
**关键路径**: 服务器准备 → 小程序账号 → 配置更新 → 部署测试 → 提交审核 