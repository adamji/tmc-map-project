# 生产环境自动增量SQL部署指南

## 🚀 系统特性

### 自动迁移功能
- **自动执行**：应用启动时自动检查和执行未执行的SQL迁移脚本
- **版本管理**：完整的数据库版本跟踪系统
- **防重复执行**：智能检测已执行的版本，避免重复执行
- **错误处理**：详细的执行日志和错误信息记录

### 支持的环境
- ✅ **生产环境 (MySQL)**：完全支持自动迁移
- ✅ **开发环境 (H2)**：支持开发和测试
- ✅ **测试环境**：与开发环境相同配置

## 📁 文件组织结构

```
tmc-map-backend/src/main/resources/sql/
├── prod-init.sql                # 生产环境初始化（版本1.0）
├── dev-init.sql                 # 开发环境初始化
├── V1.1_add_new_clubs.sql       # 版本1.1：生产环境用（MySQL）
├── V1.1_add_new_clubs.h2.sql    # 版本1.1：开发环境用（H2）- 生产环境忽略
├── V1.2_add_more_cities.sql     # 版本1.2：生产环境用（MySQL）
├── V1.2_add_more_cities.h2.sql  # 版本1.2：开发环境用（H2）- 生产环境忽略
└── V{版本号}_{描述}.sql        # 未来的迁移脚本（生产环境用）
```

### 🔒 环境隔离机制
- **生产环境(MySQL)**: 严格只执行 `V*.sql` 文件，**自动排除所有 `*.h2.sql` 文件**
- **开发环境(H2)**: 优先使用 `V*.h2.sql` 文件，如不存在则使用通用 `V*.sql` 文件
- **安全保证**: `DatabaseMigrationService` 根据数据库类型智能选择文件，确保环境隔离

## 🔄 部署流程

### 首次部署

1. **数据库准备**
   ```sql
   CREATE DATABASE tmc_map CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

2. **应用部署**
   - 应用启动时自动执行 `prod-init.sql`
   - 创建基础表结构和初始数据
   - 记录版本 `1.0` 到 `db_version` 表

3. **自动迁移**
   - `DatabaseMigrationService` 自动扫描 `V*.sql` 文件（排除 `*.h2.sql`）
   - 按版本号顺序执行未执行的迁移
   - 记录执行结果和耗时

### 增量部署

1. **添加新迁移脚本**
   ```
   V1.3_update_club_info.sql      # 生产环境使用
   V1.3_update_club_info.h2.sql   # 开发环境使用（生产环境自动忽略）
   V1.4_add_new_features.sql      # 生产环境使用
   ```

2. **应用重启**
   - 自动检测新的迁移文件
   - 生产环境仅执行 `.sql` 文件
   - 按版本顺序执行
   - 更新版本记录

## 📋 迁移脚本规范

### 文件命名规范
```
# 生产环境文件（MySQL）
V{主版本}.{次版本}_{描述}.sql

# 开发环境文件（H2）- 可选，仅在需要特殊语法时创建
V{主版本}.{次版本}_{描述}.h2.sql
```

### 环境文件选择策略
1. **生产环境(MySQL)**：
   - 只执行 `V*.sql` 文件
   - **严格排除** 所有 `V*.h2.sql` 文件
   
2. **开发环境(H2)**：
   - 优先使用 `V*.h2.sql` 文件（如果存在）
   - 如果H2版本不存在，使用通用 `V*.sql` 文件

### 脚本模板

#### 生产环境模板 (V*.sql)
```sql
-- 版本 X.Y: 功能描述（生产环境 - MySQL）
-- 执行时间: YYYY-MM-XX
-- 描述: 详细的变更说明

-- MySQL语法示例
INSERT IGNORE INTO table_name (...) VALUES (...);
ALTER TABLE table_name ADD COLUMN IF NOT EXISTS new_column VARCHAR(100);

-- 注意：版本记录由 DatabaseMigrationService 自动管理，无需手动插入
```

#### 开发环境模板 (V*.h2.sql) - 可选
```sql
-- 版本 X.Y: 功能描述（开发环境 - H2）
-- 执行时间: YYYY-MM-XX
-- 描述: H2数据库专用版本

-- H2语法示例（与MySQL有差异时才需要创建此文件）
MERGE INTO table_name (...) VALUES (...);
CREATE INDEX IF NOT EXISTS idx_name ON table_name (column);

-- 注意：此文件仅在开发环境执行，生产环境会自动忽略
```

### 最佳实践
1. **优先通用**：尽量使用MySQL兼容语法，避免创建H2专用文件
2. **幂等性**：脚本可以安全地重复执行
3. **向后兼容**：不破坏现有功能
4. **数据安全**：使用 `INSERT IGNORE` 等安全操作
5. **清晰注释**：详细说明变更内容和原因
6. **环境隔离**：确保生产环境不会误执行开发环境文件

## 🔍 版本跟踪

### db_version 表结构
```sql
CREATE TABLE db_version (
    id INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(20) NOT NULL UNIQUE,     -- 版本号
    description VARCHAR(200),                -- 描述
    sql_file VARCHAR(100) NOT NULL,          -- SQL文件名
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 执行时间
    execution_time INT,                      -- 执行耗时(毫秒)
    status ENUM('SUCCESS', 'FAILED'),        -- 执行状态
    error_message TEXT                       -- 错误信息
);
```

### 查看迁移历史
```sql
SELECT version, description, sql_file, executed_at, execution_time, status 
FROM db_version 
ORDER BY executed_at DESC;
```

## 🚨 故障处理

### 迁移失败处理
1. **查看错误日志**
   ```sql
   SELECT * FROM db_version WHERE status = 'FAILED';
   ```

2. **修复问题**
   - 修复SQL脚本中的错误
   - 手动清理问题数据（如需要）

3. **重新部署**
   - 删除失败的版本记录（如需要）
   - 重启应用，自动重试迁移

### 回滚策略
- **数据备份**：部署前备份数据库
- **版本控制**：通过Git管理SQL脚本版本
- **手动回滚**：必要时手动执行回滚SQL

## 📊 监控和日志

### 应用启动日志
```
🚀 开始数据库迁移检查...
📝 执行迁移: V1.1_add_new_clubs.sql (添加扩展俱乐部数据)
✅ 迁移成功: V1.1_add_new_clubs.sql (耗时: 245ms)
📝 执行迁移: V1.2_add_more_cities.sql (扩展更多城市的俱乐部数据)
✅ 迁移成功: V1.2_add_more_cities.sql (耗时: 189ms)
✅ 数据库迁移完成
```

### 迁移API接口
```
GET /api/migration/history  # 查看迁移历史
```

## 🎯 示例场景

### 场景1：新增俱乐部数据
1. 创建 `V1.3_add_spring_clubs.sql`
2. 包含春季新增俱乐部数据
3. 部署应用，自动执行迁移

### 场景2：表结构变更
```sql
-- V1.4_add_club_rating.sql
ALTER TABLE club ADD COLUMN IF NOT EXISTS rating DECIMAL(3,2) DEFAULT 0.0 COMMENT '评分';
UPDATE club SET rating = 4.5 WHERE rating = 0.0;
```

### 场景3：数据修正
```sql
-- V1.5_fix_contact_info.sql
UPDATE club SET contact_wechat = CONCAT(contact_phone, '_wechat') 
WHERE contact_wechat IS NULL OR contact_wechat = '';
```

## ✅ 部署检查清单

- [ ] 数据库备份已完成
- [ ] SQL脚本已测试
- [ ] 版本号正确且递增
- [ ] 脚本具有幂等性
- [ ] 应用配置正确
- [ ] 监控系统就绪

---

**注意**：此系统已在生产环境配置完成，每次应用启动都会自动执行增量迁移。请确保所有SQL脚本都经过充分测试！ 