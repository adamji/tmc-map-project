-- 版本 1.0: 创建数据库版本管理表
-- 执行时间: 2024-12-XX
-- 描述: 创建用于跟踪数据库迁移版本的表

-- 创建数据库版本管理表
CREATE TABLE IF NOT EXISTS db_version (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '版本ID',
    version VARCHAR(20) NOT NULL UNIQUE COMMENT '版本号',
    description VARCHAR(200) COMMENT '版本描述',
    sql_file VARCHAR(100) NOT NULL COMMENT 'SQL文件名',
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
    execution_time INT COMMENT '执行耗时(毫秒)',
    status ENUM('SUCCESS', 'FAILED') DEFAULT 'SUCCESS' COMMENT '执行状态',
    error_message TEXT COMMENT '错误信息',
    INDEX idx_version (version),
    INDEX idx_executed_at (executed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据库版本管理表';

-- 插入初始版本记录
INSERT INTO db_version (version, description, sql_file) VALUES 
('1.0', '创建数据库版本管理表', 'V1.0_create_version_table.sql'); 