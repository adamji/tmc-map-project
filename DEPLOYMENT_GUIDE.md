# 头马俱乐部地图小程序上线部署指南

## 📋 概述
本指南详细说明了如何将头马俱乐部地图小程序从开发环境部署到生产环境。

## 🎯 部署步骤

### 第一阶段：服务器端部署 (关键步骤)

#### 1. 准备生产环境服务器
- [ ] 准备云服务器（推荐阿里云/腾讯云）
- [ ] 安装Java 17+环境
- [ ] 安装MySQL 8.0+数据库
- [ ] 配置域名解析 `api.tmcmap.com` 指向服务器IP
- [ ] 申请SSL证书并配置HTTPS

#### 2. 数据库初始化
```bash
# 1. 登录MySQL
mysql -u root -p

# 2. 执行初始化脚本
source /path/to/tmc-map-backend/src/main/resources/sql/production-init.sql
```

#### 3. 配置生产环境参数
编辑 `application-prod.yml` 文件，更新以下配置：
- [ ] MySQL数据库连接信息
- [ ] 腾讯地图API密钥
- [ ] 高德地图API密钥（如使用）

#### 4. 部署后端服务
```bash
# 1. 构建项目
cd tmc-map-backend
mvn clean package -Pprod

# 2. 部署到服务器
scp target/tmc-map-backend-1.0.0.jar user@your-server:/opt/tmcmap/

# 3. 启动服务
java -jar -Dspring.profiles.active=prod /opt/tmcmap/tmc-map-backend-1.0.0.jar
```

#### 5. 验证后端服务
```bash
# 测试API接口
curl https://api.tmcmap.com/api/clubs
```

### 第二阶段：微信小程序配置

#### 1. 申请小程序账号
- [ ] 在[微信公众平台](https://mp.weixin.qq.com)注册小程序账号
- [ ] 完成小程序信息认证
- [ ] 获取小程序AppID

#### 2. 配置小程序信息
按照 `uniapp-tmc-map/小程序信息设置表.md` 中的内容进行配置：

**基本信息**
- [ ] 小程序名称：头马俱乐部地图
- [ ] 小程序简介：（按文档中的描述）
- [ ] 上传小程序头像 (1024x1024)

**服务类目**
- [ ] 选择"生活服务 > 综合生活服务平台"

**服务器域名配置**
在微信小程序后台 > 开发 > 开发设置 > 服务器域名，添加：
- [ ] request合法域名：`https://api.tmcmap.com`
- [ ] request合法域名：`https://apis.map.qq.com`
- [ ] downloadFile合法域名：`https://rt0.map.gtimg.com`
- [ ] downloadFile合法域名：`https://rt1.map.gtimg.com`
- [ ] downloadFile合法域名：`https://rt2.map.gtimg.com`
- [ ] downloadFile合法域名：`https://rt3.map.gtimg.com`

#### 3. 配置隐私权限
- [ ] 位置信息权限：`scope.userLocation`
- [ ] 隐私接口：`getLocation`, `chooseLocation`
- [ ] 填写隐私说明

### 第三阶段：前端代码配置

#### 1. 更新配置文件
- [ ] 修改 `manifest.json` 中的 `appid` 为真实的小程序AppID
- [ ] 确认 `club.js` 中的生产环境API地址为 `https://api.tmcmap.com`

#### 2. 代码优化
- [ ] 移除所有 `console.log` 调试代码
- [ ] 将 `USE_MOCK_DATA` 设置为 `false`
- [ ] 检查代码中的TODO和FIXME注释

#### 3. 构建生产版本
```bash
# 进入前端项目目录
cd uniapp-tmc-map

# 安装依赖
npm install

# 构建生产版本
npm run build:mp-weixin
```

### 第四阶段：测试与发布

#### 1. 开发者工具测试
- [ ] 使用微信开发者工具导入项目
- [ ] 完成真机预览测试
- [ ] 测试所有核心功能：
  - [ ] 地图显示正常
  - [ ] 俱乐部标记显示
  - [ ] 点击标记显示详情
  - [ ] 筛选功能正常
  - [ ] 导航功能正常
  - [ ] 定位功能正常

#### 2. 提交审核
- [ ] 在微信开发者工具中点击"上传"
- [ ] 填写版本号和项目备注
- [ ] 在微信公众平台提交审核
- [ ] 填写版本描述和审核说明

#### 3. 准备审核材料
- [ ] 小程序功能截图
- [ ] 用户使用说明
- [ ] 如有必要，准备演示视频

### 第五阶段：发布上线

#### 1. 审核通过后
- [ ] 在微信公众平台点击"发布"
- [ ] 测试线上版本功能
- [ ] 准备用户反馈收集渠道

#### 2. 监控与维护
- [ ] 监控服务器运行状态
- [ ] 监控数据库性能
- [ ] 收集用户反馈
- [ ] 准备后续版本更新计划

## ⚠️ 注意事项

### 安全配置
- [ ] 确保所有API接口使用HTTPS
- [ ] 数据库连接使用SSL
- [ ] 配置防火墙规则
- [ ] 定期更新系统补丁

### 性能优化
- [ ] 配置CDN加速（如需要）
- [ ] 数据库索引优化
- [ ] API响应缓存配置
- [ ] 图片资源压缩

### 监控告警
- [ ] 配置服务器监控
- [ ] 配置数据库监控
- [ ] 配置API接口监控
- [ ] 设置告警通知

## 📞 应急联系

如果在部署过程中遇到问题，请检查：
1. 服务器日志：`/opt/tmcmap/logs/tmc-map-backend.log`
2. 数据库连接状态
3. 域名解析是否正确
4. SSL证书是否有效

## 🔄 回滚计划

如果发布后发现问题，可以：
1. 在微信公众平台回滚到上一版本
2. 在服务器上回滚到上一版本JAR包
3. 恢复数据库备份（如有数据变更）

---

**部署完成后，记得更新这个检查清单的完成状态！** 