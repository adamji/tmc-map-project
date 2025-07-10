-- 版本 1.0: 创建测试用数据库版本管理表
-- 执行时间: 2024-12-XX
-- 描述: 创建用于测试的版本管理表

-- 创建数据库版本管理表 (测试环境)
CREATE TABLE IF NOT EXISTS db_version (
    id INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(200),
    sql_file VARCHAR(100) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_time INT,
    status VARCHAR(10) DEFAULT 'SUCCESS',
    error_message TEXT,
    INDEX idx_version (version),
    INDEX idx_executed_at (executed_at)
);

-- 注意：不在这里插入版本记录，由迁移服务自动管理 