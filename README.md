# 头马俱乐部地图小程序

基于uniapp + Spring Boot的头马俱乐部地图应用，支持地图展示、筛选查询、导航等功能。

## 项目架构

本项目采用前后端分离架构：

- **前端**：uniapp框架，兼容微信小程序
- **后端**：Spring Boot + MyBatis Plus + MySQL
- **地图服务**：微信小程序地图组件

## 功能特性

### 前端功能
- 🗺️ 地图展示所有头马俱乐部位置
- 📅 按例会时间（星期几）筛选俱乐部
- 📍 显示用户当前位置
- 🏢 点击俱乐部显示详细信息
- 🧭 一键导航到俱乐部
- 📱 完整的移动端适配

### 后端功能
- 🔍 俱乐部列表查询（支持城市、时间筛选）
- 📋 俱乐部详情查询
- 📏 距离计算和附近俱乐部查询
- 🗺️ 路线规划计算
- 📖 完整的API文档（Swagger）

## 项目结构

```
toaster-master-family/
├── uniapp-tmc-map/          # 前端uniapp项目
│   ├── components/          # 组件
│   │   ├── MapView.vue      # 地图组件
│   │   ├── DatePicker.vue   # 日期选择器
│   │   └── ClubCard.vue     # 俱乐部卡片
│   ├── pages/               # 页面
│   │   ├── index/           # 首页（地图页）
│   │   ├── club-detail/     # 俱乐部详情页
│   │   └── navigation/      # 导航页
│   ├── services/            # API接口封装
│   ├── store/               # 状态管理
│   ├── utils/               # 工具函数
│   └── static/              # 静态资源
│
├── tmc-map-backend/         # 后端Java项目
│   ├── src/main/java/com/tmcmap/
│   │   ├── controller/      # 控制器层
│   │   ├── service/         # 业务服务层
│   │   ├── repository/      # 数据访问层
│   │   ├── model/           # 数据模型
│   │   └── util/            # 工具类
│   ├── src/main/resources/
│   │   ├── application.yml  # 配置文件
│   │   └── sql/init.sql     # 数据库初始化脚本
│   └── pom.xml              # Maven依赖
│
├── architecture.md          # 架构设计文档
├── prd.md                   # 产品需求文档
├── mrd.md                   # 市场需求文档
└── README.md                # 项目说明
```

## 技术栈

### 前端技术栈
- **uniapp**：跨平台开发框架
- **Vue 3**：前端框架
- **Pinia**：状态管理
- **微信小程序地图**：地图服务
- **ES6+**：JavaScript语法

### 后端技术栈
- **Spring Boot 3.2**：主框架
- **MyBatis Plus**：数据访问框架
- **MySQL 8.0**：数据库
- **MapStruct**：对象映射
- **SpringDoc**：API文档生成
- **Lombok**：代码简化

## 快速开始

### 环境要求
- **前端**：HBuilderX 或 Node.js 16+
- **后端**：JDK 17+, Maven 3.6+, MySQL 8.0+

### 后端启动

1. **创建数据库**
```sql
CREATE DATABASE tmc_map CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. **执行初始化脚本**
```bash
mysql -u root -p tmc_map < tmc-map-backend/src/main/resources/sql/init.sql
```

3. **修改配置文件**
```yaml
# tmc-map-backend/src/main/resources/application.yml
spring:
  datasource:
    username: your_username
    password: your_password
```

4. **启动后端服务**
```bash
cd tmc-map-backend
mvn spring-boot:run
```

服务启动后访问 http://localhost:8080/api/swagger-ui.html 查看API文档

### 前端启动

1. **导入项目**
   - 使用HBuilderX导入 `uniapp-tmc-map` 项目

2. **配置API地址**
```javascript
// uniapp-tmc-map/services/club.js
const API_BASE = 'https://your-api-domain.com/api'  // 修改为实际后端地址
```

3. **运行项目**
   - 在HBuilderX中选择"运行" -> "运行到小程序模拟器" -> "微信开发者工具"

## API接口

### 俱乐部接口
- `GET /api/clubs` - 获取俱乐部列表
- `GET /api/clubs/{id}` - 获取俱乐部详情
- `GET /api/clubs/nearby` - 获取附近俱乐部

### 导航接口
- `POST /api/navigation/calculate` - 计算导航路线
- `GET /api/navigation/distance` - 计算距离

详细API文档请访问：http://localhost:8080/api/swagger-ui.html

## 部署说明

### 后端部署
1. **打包应用**
```bash
mvn clean package -DskipTests
```

2. **运行jar包**
```bash
java -jar target/tmc-map-backend-1.0.0.jar
```

### 前端部署
1. **构建小程序**
   - 在HBuilderX中选择"发行" -> "小程序-微信"

2. **上传审核**
   - 使用微信开发者工具上传代码包
   - 在微信公众平台提交审核

## 开发规范

### 代码规范
- **Java**：遵循阿里巴巴Java开发手册
- **JavaScript**：遵循ESLint推荐规范
- **Vue**：遵循Vue官方风格指南

### 提交规范
- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 代码重构

## 许可证

MIT License

## 联系方式

如有问题请提交Issue或联系开发团队。 