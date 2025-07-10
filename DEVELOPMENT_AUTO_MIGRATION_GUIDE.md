# 开发环境自动数据库迁移指南

## 📋 概述

开发环境现已支持自动增量数据库迁移，与生产环境保持一致的迁移策略。使用H2内存数据库，支持快速开发和测试。

## 🎯 迁移系统特性

### 核心功能
- ✅ **自动迁移检测**: 应用启动时自动扫描并执行新的迁移文件
- ✅ **H2兼容性**: 支持H2特定语法和MySQL兼容模式
- ✅ **版本管理**: 完整的迁移历史记录和状态跟踪
- ✅ **错误处理**: 迁移失败时记录详细错误信息
- ✅ **智能选择**: 优先使用H2专用文件，降级使用通用文件

### 数据库配置
```yaml
# application-dev.yml
spring:
  datasource:
    driver-class-name: org.h2.Driver
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MODE=MySQL;DATABASE_TO_LOWER=TRUE
    username: sa
    password: 
  
  sql:
    init:
      mode: always  # 启用自动迁移
      data-locations: classpath:sql/dev-init.sql
```

## 📁 文件结构

```
src/main/resources/sql/
├── dev-init.sql              # 开发环境初始化（仅首次执行）
├── V1.1_add_new_clubs.sql    # 通用迁移文件
├── V1.1_add_new_clubs.h2.sql # H2专用迁移文件（优先使用）
├── V1.2_add_more_cities.sql  # 通用迁移文件
└── V1.2_add_more_cities.h2.sql # H2专用迁移文件（优先使用）
```

## 🔄 迁移执行逻辑

### 文件选择策略
1. **H2数据库**：
   - 优先使用 `V*.h2.sql` 文件
   - 如果H2版本不存在，使用通用 `V*.sql` 文件
   
2. **MySQL数据库**：
   - 只使用通用 `V*.sql` 文件
   - 忽略 `V*.h2.sql` 文件

### 执行顺序
1. 检查 `db_version` 表是否存在，不存在则创建
2. 获取已执行的迁移版本列表
3. 扫描 `sql/` 目录下的所有 `V*.sql` 文件
4. 按版本号排序，执行未执行的迁移
5. 记录执行结果到 `db_version` 表

## 📝 开发工作流

### 1. 创建新迁移
当需要修改数据库结构时：

```bash
# 创建通用版本（MySQL兼容）
touch src/main/resources/sql/V1.3_add_user_table.sql

# 创建H2专用版本（如果需要特殊语法）
touch src/main/resources/sql/V1.3_add_user_table.h2.sql
```

### 2. H2专用语法示例
```sql
-- V1.3_add_user_table.h2.sql
-- H2版本使用MERGE语句避免重复插入

MERGE INTO club (name, address, city, ...) VALUES 
('新俱乐部', '新地址', '新城市', ...);
```

### 3. 测试迁移
```bash
# 启动开发服务器
cd tmc-map-backend
./mvnw spring-boot:run -Pdev

# 查看迁移日志
# 🚀 开始数据库迁移检查... (数据库类型: H2)
# 📝 执行迁移: V1.1_add_new_clubs.h2.sql (add new clubs)
# ✅ 迁移成功: V1.1_add_new_clubs.h2.sql (耗时: 45ms)
```

## 🔍 版本管理表

开发环境的 `db_version` 表结构：
```sql
CREATE TABLE db_version (
    id INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(20) NOT NULL UNIQUE,      -- 版本号 (如: 1.1)
    description VARCHAR(200),                 -- 描述信息
    sql_file VARCHAR(100) NOT NULL,           -- 执行的SQL文件名
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 执行时间
    execution_time INT,                       -- 执行耗时(毫秒)
    status VARCHAR(10) DEFAULT 'SUCCESS',     -- 执行状态
    error_message TEXT                        -- 错误信息
);
```

## 🛠️ 开发环境专用功能

### 1. H2控制台访问
```
URL: http://localhost:8080/h2-console
JDBC URL: jdbc:h2:mem:testdb
用户名: sa
密码: (空)
```

### 2. 查看迁移历史
```sql
SELECT version, description, sql_file, executed_at, execution_time, status 
FROM db_version 
ORDER BY executed_at DESC;
```

### 3. 重置开发环境
由于使用内存数据库，每次重启应用都会：
- 重新创建所有表结构
- 重新执行初始化脚本
- 重新执行所有迁移文件

## ⚠️ 开发注意事项

### 1. H2与MySQL差异
- **外键约束**: H2更严格，需要注意约束定义
- **数据类型**: 某些类型映射可能不同
- **索引语法**: H2使用 `CREATE INDEX IF NOT EXISTS`

### 2. 数据持久化
- H2使用内存数据库，应用重启数据丢失
- 如需持久化，修改配置使用文件数据库：
  ```yaml
  url: jdbc:h2:file:./data/devdb;MODE=MySQL
  ```

### 3. 测试数据
开发环境包含额外的测试数据：
- 测试俱乐部1、测试俱乐部2
- 用于开发和调试的示例数据

## 🔧 故障排除

### 1. 迁移失败
```
❌ 迁移失败: V1.X_xxx.h2.sql - Table "XXX" already exists
```
**解决方案**: 检查迁移脚本中的 `IF NOT EXISTS` 子句

### 2. H2语法错误
```
❌ 迁移失败: 语法错误
```
**解决方案**: 创建专用的 `.h2.sql` 版本，使用H2兼容语法

### 3. 数据库连接失败
```
❌ 数据库迁移失败: Connection refused
```
**解决方案**: 检查H2数据库配置和依赖

## 📊 性能优化

### 1. 开发环境配置
- 使用内存数据库提高速度
- 较短的连接池配置
- 启用SQL日志便于调试

### 2. 迁移优化
- H2专用文件使用 `MERGE` 语句避免重复
- 合理的事务边界
- 批量插入优化

## 🚀 下一步

1. **添加新功能**：创建对应的迁移文件
2. **测试验证**：在开发环境验证迁移效果
3. **同步生产**：确保生产环境有对应的MySQL版本
4. **文档更新**：及时更新迁移记录和说明

开发环境的自动迁移系统现已就绪，支持与生产环境一致的增量部署策略！🎉 