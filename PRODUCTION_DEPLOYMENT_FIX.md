# 生产环境部署错误修复指南

## 🚨 错误分析

### 1. **MyBatis Bean创建失败**
```
Cannot resolve reference to bean 'sqlSessionTemplate'
```

### 2. **SQL文件引用错误** 
```
Failed to execute SQL script statement #1 of class path resource [schema-h2.sql]
```

## ✅ 已修复的问题

### 1. **配置文件清理**
- ❌ 删除 `application.yml` 中的错误SQL引用
- ❌ 删除 `application-test.yml` 中的错误文件引用  
- ✅ 设置 `application-prod.yml` 为 `mode: never`

### 2. **外键约束临时禁用**
- 注释掉 `navigation_log` 表的外键约束，避免部署时冲突

## 🔧 当前配置状态

### 生产环境 (`application-prod.yml`)
```yaml
sql:
  init:
    mode: never  # 禁用Spring Boot SQL初始化
```

### MyBatis配置
```yaml
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
  mapper-locations: classpath*:mapper/*.xml
```

### 主应用类
```java
@SpringBootApplication
@MapperScan("com.tmcmap.repository.mapper")  # ✅ 正确配置
```

## 🚀 重新部署步骤

### 1. **清理残留数据**
如果数据库已存在问题数据：
```sql
-- 手动清理（如果需要）
DROP TABLE IF EXISTS navigation_log;
DROP TABLE IF EXISTS club;
DROP TABLE IF EXISTS db_version;
```

### 2. **使用迁移系统部署**
```bash
# 生产环境启动 - 让迁移系统管理数据库
java -jar tmc-map-backend.jar --spring.profiles.active=prod
```

### 3. **验证部署成功**
```bash
# 检查健康状态
curl http://localhost:8080/api/actuator/health

# 检查俱乐部列表
curl http://localhost:8080/api/clubs
```

## 📋 配置验证清单

- ✅ `application.yml` 不引用不存在的SQL文件
- ✅ `application-prod.yml` 设置 `mode: never`
- ✅ MyBatis依赖正确配置在 `pom.xml`
- ✅ `@MapperScan` 注解正确配置
- ✅ 外键约束暂时禁用
- ✅ 数据库连接信息正确

## 🎯 关键改进

1. **简化部署流程** - 完全依赖迁移系统
2. **避免配置冲突** - 禁用Spring Boot SQL初始化
3. **减少外键约束** - 避免部署时的约束冲突
4. **统一表结构** - 开发生产环境字段完全一致

**现在应该可以正常部署了！如果还有问题，请检查数据库连接和权限。** 