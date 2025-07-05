# 后端功能测试指南

本文档介绍如何测试头马俱乐部地图后端API功能。

## 🚀 快速开始

### 1. 启动后端服务

```bash
# 进入后端项目目录
cd tmc-map-backend

# 使用Maven启动项目
mvn spring-boot:run

# 或者先编译再运行
mvn clean compile
mvn spring-boot:run
```

服务启动后，默认运行在 `http://localhost:8080/api`

### 2. 验证服务启动

访问健康检查接口：
```bash
curl http://localhost:8080/api/actuator/health
```

## 📋 API接口列表

### 俱乐部管理接口

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| 获取俱乐部列表 | GET | `/clubs` | 支持城市、星期几、位置筛选 |
| 获取俱乐部详情 | GET | `/clubs/{id}` | 根据ID获取详情 |
| 获取附近俱乐部 | GET | `/clubs/nearby` | 根据坐标获取附近俱乐部 |

### 导航服务接口

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| 计算两点距离 | GET | `/navigation/distance` | 计算直线距离 |
| 计算导航路线 | POST | `/navigation/calculate` | 计算详细路线 |

## 🧪 测试方法

### 方法一：Swagger UI测试（推荐）

1. 启动后端服务
2. 浏览器访问：`http://localhost:8080/api/swagger-ui.html`
3. 在Swagger界面中测试各个API接口

**优点**：
- 图形化界面，操作简单
- 自动生成请求参数表单
- 实时查看响应结果
- 支持参数验证

### 方法二：命令行测试

#### 使用提供的测试脚本

```bash
# 给脚本执行权限（Linux/Mac）
chmod +x test-api.sh

# 运行测试脚本
./test-api.sh
```

#### 手动curl测试

```bash
# 1. 获取所有俱乐部
curl -X GET "http://localhost:8080/api/clubs" \
  -H "Content-Type: application/json"

# 2. 根据城市筛选
curl -X GET "http://localhost:8080/api/clubs?city=北京" \
  -H "Content-Type: application/json"

# 3. 根据星期几筛选（周六）
curl -X GET "http://localhost:8080/api/clubs?weekday=6" \
  -H "Content-Type: application/json"

# 4. 获取俱乐部详情
curl -X GET "http://localhost:8080/api/clubs/1" \
  -H "Content-Type: application/json"

# 5. 获取附近俱乐部
curl -X GET "http://localhost:8080/api/clubs/nearby?lat=39.9042&lng=116.4074&radius=10" \
  -H "Content-Type: application/json"

# 6. 计算距离
curl -X GET "http://localhost:8080/api/navigation/distance?fromLat=39.9042&fromLng=116.4074&toLat=39.9122&toLng=116.4241" \
  -H "Content-Type: application/json"

# 7. 计算导航路线
curl -X POST "http://localhost:8080/api/navigation/calculate" \
  -H "Content-Type: application/json" \
  -d '{
    "fromLat": 39.9042,
    "fromLng": 116.4074,
    "toLat": 39.9122,
    "toLng": 116.4241,
    "mode": "driving"
  }'
```

### 方法三：Postman测试

1. 导入 `postman-collection.json` 文件到Postman
2. 确保环境变量 `baseUrl` 设置为 `http://localhost:8080/api`
3. 运行集合中的各个请求

### 方法四：单元测试

运行单元测试：

```bash
# 运行所有测试
mvn test

# 运行特定测试类
mvn test -Dtest=ClubControllerTest

# 运行测试并生成报告
mvn test jacoco:report
```

## 📊 测试用例

### 正常功能测试

1. **俱乐部列表查询**
   - 获取所有俱乐部
   - 按城市筛选
   - 按星期几筛选
   - 按位置筛选

2. **俱乐部详情查询**
   - 查询存在的俱乐部
   - 查询不存在的俱乐部

3. **附近俱乐部查询**
   - 不同半径范围查询
   - 不同位置查询

4. **导航功能**
   - 距离计算
   - 路线规划

### 异常情况测试

1. **参数验证**
   - 缺少必需参数
   - 参数格式错误
   - 参数值超出范围

2. **业务异常**
   - 查询不存在的资源
   - 无效的坐标信息

3. **系统异常**
   - 数据库连接异常
   - 第三方服务异常

## 📝 响应格式

所有API响应都遵循统一格式：

```json
{
  "success": true/false,
  "code": 200,
  "message": "操作成功",
  "data": {响应数据},
  "timestamp": "2024-01-01T12:00:00"
}
```

### 常见状态码

- `200`：操作成功
- `400`：请求参数错误
- `404`：资源不存在
- `500`：服务器内部错误

## 🔧 测试环境配置

### 数据库配置

开发环境使用H2内存数据库，测试数据在 `data-h2.sql` 中定义。

### 日志配置

测试时可以调整日志级别查看详细信息：

```yaml
logging:
  level:
    com.tmcmap: debug
```

## 📈 性能测试

可以使用以下工具进行性能测试：

1. **Apache Bench (ab)**
```bash
ab -n 1000 -c 10 http://localhost:8080/api/clubs
```

2. **JMeter**
- 创建测试计划
- 配置并发用户数
- 执行压力测试

## 🐛 常见问题

### 1. 端口占用
如果8080端口被占用，可以修改 `application.yml` 中的端口配置。

### 2. 数据库连接错误
检查数据库配置和连接信息。

### 3. 依赖问题
运行 `mvn clean install` 重新下载依赖。

## 📚 相关文档

- [Spring Boot测试指南](https://spring.io/guides/gs/testing-web/)
- [MockMvc测试](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#spring-mvc-test-framework)
- [Swagger OpenAPI文档](https://swagger.io/specification/)

---

如有测试相关问题，请查看日志输出或联系开发团队。 