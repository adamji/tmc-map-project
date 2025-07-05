# 🚀 TMC Map 快速入门指南（无需Docker）

## 🎯 最简单的部署方式

**你只需要：**
- ✅ Git（用于代码管理）
- ✅ GitHub账号
- ❌ 不需要Docker
- ❌ 不需要服务器

## 📋 操作步骤

### 第1步：创建GitHub仓库

1. 访问 [GitHub](https://github.com/new)
2. 创建新仓库：
   - Repository name: `tmc-map-project`
   - Description: `TMC Map - WeChat Mini Program`
   - 选择 **Public** 
   - ✅ Add a README file
   - ✅ Add .gitignore (选择Java)

### 第2步：上传代码

在项目根目录运行：

```bash
# 使用极简版脚本（只需要Git）
upload-to-github.bat 你的GitHub用户名 tmc-map-project

# 示例：
# upload-to-github.bat myusername tmc-map-project
```

**脚本会自动：**
- 初始化Git仓库
- 添加远程仓库
- 提交所有代码
- 推送到GitHub

### 第3步：选择部署方式

#### 🌟 方式1：微信云托管（推荐）

1. **登录微信云开发控制台**
   - 访问 https://console.cloud.tencent.com/tcb

2. **创建云托管服务**
   - 点击"云托管" → "新建服务"
   - 服务名称：`tmc-map-backend`
   - 部署方式：**代码仓库**

3. **配置GitHub仓库**
   - 仓库地址：`https://github.com/你的用户名/tmc-map-project`
   - 分支：`main`
   - 构建目录：`tmc-map-backend/`
   - Dockerfile路径：`tmc-map-backend/Dockerfile`

4. **等待自动部署**
   - 云托管会自动拉取代码
   - 在云端构建Docker镜像
   - 自动部署运行

#### 🚀 方式2：GitHub Actions自动部署

1. **在GitHub仓库中配置Secrets**
   - 进入你的仓库
   - Settings → Secrets and variables → Actions
   - 点击 "New repository secret"

2. **添加必要的Secrets**
   ```
   DOCKER_USERNAME: 你的Docker Hub用户名
   DOCKER_PASSWORD: 你的Docker Hub密码
   ```

3. **推送代码自动部署**
   - 每次推送到main分支
   - GitHub Actions自动构建镜像
   - 自动部署到云端

## 🎉 成功！无需Docker

现在你的项目已经：
- ✅ 上传到GitHub
- ✅ 可以在云端自动构建
- ✅ 可以自动部署运行
- ✅ 零本地依赖（除了Git）

## 📝 常见问题

### Q: 我需要安装Docker吗？
**A: 不需要！** 所有Docker操作都在云端完成。

### Q: 如果Git推送失败怎么办？
**A: 检查以下几点：**
1. 确保你已经在GitHub创建了仓库
2. 确保仓库名字拼写正确
3. 确保你有仓库的写入权限

### Q: 如何查看部署状态？
**A: 访问以下链接：**
- GitHub Actions: `https://github.com/你的用户名/仓库名/actions`
- 微信云托管: `https://console.cloud.tencent.com/tcb`

### Q: 可以本地测试吗？
**A: 可以！使用以下命令：**
```bash
# 仅在需要本地测试时使用
docker-compose up -d
```

## 🎯 下一步

1. **访问你的GitHub仓库** 确认代码上传成功
2. **选择部署方式** 微信云托管或GitHub Actions
3. **等待自动部署** 所有操作都在云端完成
4. **访问你的应用** 通过提供的URL访问

**恭喜！你已经成功部署了TMC Map项目！** 🎉 