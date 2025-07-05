# 🚀 TMC Map 微信云托管部署教程

## 📋 部署流程总览

### 阶段1：环境准备 ✅
### 阶段2：代码容器化 ✅  
### 阶段3：云托管部署 🔄
### 阶段4：域名配置 ⏳
### 阶段5：前端集成 ⏳

---

## 🛠️ 第一步：创建云开发环境

### 1. 登录云开发控制台
```bash
访问: https://console.cloud.tencent.com/tcb
```

### 2. 创建环境
```bash
1. 点击"新建环境"
2. 选择"按量计费"
3. 环境名称: tmc-map
4. 地域: 选择就近地域（如上海）
5. 记录下环境ID（类似: tmc-map-xxx）
```

### 3. 开通云托管服务
```bash
1. 进入刚创建的环境
2. 左侧菜单 -> 云托管 -> 服务管理
3. 点击"开通云托管"
4. 确认开通
```

---

## 🐳 第二步：构建和推送镜像

### 1. 本地构建镜像
```bash
# 进入项目根目录
cd /path/to/toaster-master-family

# 构建Docker镜像
docker build -t tmc-map-backend:latest ./tmc-map-backend

# 验证镜像
docker images | grep tmc-map-backend
```

### 2. 测试镜像
```bash
# 本地运行测试
docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=dev tmc-map-backend:latest

# 访问测试接口
curl http://localhost:8080/api/clubs

# 停止容器
docker stop $(docker ps -q --filter ancestor=tmc-map-backend:latest)
```

### 3. 推送到腾讯云镜像仓库
```bash
# 登录腾讯云容器镜像服务
docker login ccr.ccs.tencentyun.com

# 标记镜像
docker tag tmc-map-backend:latest ccr.ccs.tencentyun.com/your-namespace/tmc-map-backend:latest

# 推送镜像
docker push ccr.ccs.tencentyun.com/your-namespace/tmc-map-backend:latest
```

---

## ☁️ 第三步：部署到云托管

### 方式一：使用控制台部署

#### 1. 创建服务
```bash
1. 进入云托管控制台
2. 点击"新建服务"
3. 服务名称: tmc-map-backend
4. 选择"镜像部署"
```

#### 2. 配置镜像
```bash
镜像地址: ccr.ccs.tencentyun.com/your-namespace/tmc-map-backend:latest
端口: 8080
CPU: 1核
内存: 2GB
实例数量: 1-10 (自动伸缩)
```

#### 3. 环境变量配置
```bash
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
MYSQL_HOST=你的数据库地址
MYSQL_DATABASE=tmc_map
MYSQL_USERNAME=数据库用户名
MYSQL_PASSWORD=数据库密码
TENCENT_MAP_KEY=你的腾讯地图API密钥
```

#### 4. 高级配置
```bash
健康检查:
- 检查路径: /api/health
- 检查端口: 8080
- 延迟时间: 30秒

日志配置:
- 自定义日志路径: /app/logs
- 日志收集: 开启
```

### 方式二：使用CLI部署

#### 1. 安装CLI工具
```bash
npm install -g @cloudbase/cli
```

#### 2. 登录认证
```bash
tcb login
```

#### 3. 部署应用
```bash
# 修改 cloudbaserc.json 中的环境ID
# 然后执行部署
tcb framework deploy
```

---

## 🌐 第四步：配置自定义域名（可选）

### 1. 添加域名
```bash
1. 云托管控制台 -> 服务详情 -> 访问配置
2. 点击"添加域名"
3. 输入域名: api.tmcmap.com
4. 选择SSL证书（或上传）
```

### 2. DNS解析配置
```bash
# 在域名服务商处添加CNAME记录
主机记录: api
记录类型: CNAME
记录值: 云托管提供的域名（如xxx.tcb.qcloud.la）
TTL: 600
```

### 3. SSL证书配置
```bash
# 如果没有SSL证书，可以申请免费证书
1. 腾讯云控制台 -> SSL证书
2. 申请免费的DV证书
3. 验证域名所有权
4. 下载证书并上传到云托管
```

---

## 📱 第五步：前端配置

### 1. 更新请求地址
```javascript
// uniapp-tmc-map/src/utils/request.js
const baseURL = 'https://api.tmcmap.com'; // 你的云托管域名

// 或者使用云托管默认域名
// const baseURL = 'https://tmc-map-backend-xxx.tcb.qcloud.la';
```

### 2. 小程序域名配置
```bash
1. 微信公众平台 -> 开发 -> 开发设置
2. 服务器域名 -> request合法域名
3. 添加: https://api.tmcmap.com
4. 或添加云托管默认域名
```

---

## 📊 第六步：监控和运维

### 1. 查看服务状态
```bash
# 使用控制台
1. 云托管控制台 -> 服务详情
2. 查看实例状态、CPU、内存使用情况

# 使用CLI
tcb env:list
tcb service:list
```

### 2. 查看日志
```bash
# 控制台查看
云托管控制台 -> 服务详情 -> 日志

# CLI查看实时日志
tcb service:log --service-name tmc-map-backend --follow
```

### 3. 扩缩容配置
```bash
# 自动扩缩容规则
最小实例数: 0 (节省成本)
最大实例数: 10 (应对突发流量)
CPU扩容阈值: 70%
内存扩容阈值: 80%
```

---

## 🚨 故障排查

### 常见问题及解决方案

#### 1. 服务启动失败
```bash
# 检查日志
tcb service:log --service-name tmc-map-backend

# 常见原因:
- 端口配置错误
- 环境变量缺失
- 数据库连接失败
- 内存不足
```

#### 2. 连接数据库失败
```bash
# 检查环境变量
MYSQL_HOST=正确的数据库地址
MYSQL_PORT=3306
MYSQL_DATABASE=tmc_map
MYSQL_USERNAME=数据库用户名
MYSQL_PASSWORD=数据库密码

# 网络检查
- 确保数据库允许云托管的IP访问
- 检查VPC配置
```

#### 3. 小程序调用失败
```bash
# 检查域名配置
1. 确保域名已添加到微信小程序后台
2. 确保使用HTTPS协议
3. 检查域名是否已备案（如使用自定义域名）
```

---

## 💰 成本优化建议

### 1. 合理配置资源
```bash
# 生产环境推荐配置
CPU: 1核 (可根据实际负载调整)
内存: 2GB
最小实例: 0 (深夜自动缩容到0)
最大实例: 5 (应对峰值流量)
```

### 2. 使用预留资源
```bash
# 如果流量稳定，可考虑购买预留资源包
- 比按量计费便宜20-30%
- 适合长期稳定运行的服务
```

### 3. 监控成本
```bash
# 定期查看费用
1. 腾讯云控制台 -> 费用中心
2. 查看云托管的详细费用
3. 根据实际使用情况调整配置
```

---

## ✅ 部署检查清单

- [ ] 云开发环境已创建
- [ ] 云托管服务已开通
- [ ] Docker镜像构建成功
- [ ] 镜像推送到仓库
- [ ] 云托管服务部署成功
- [ ] 环境变量配置正确
- [ ] 数据库连接正常
- [ ] 接口测试通过
- [ ] 域名配置完成（可选）
- [ ] SSL证书配置（可选）
- [ ] 小程序域名白名单配置
- [ ] 监控和日志配置

---

## 📞 技术支持

### 官方文档
- 云托管官方文档: https://cloud.tencent.com/document/product/1243
- 微信小程序文档: https://developers.weixin.qq.com/miniprogram/dev/

### 社区支持
- 腾讯云开发者社区
- 微信开发者社区

**🎉 恭喜！你的TMC Map应用已成功部署到微信云托管！** 