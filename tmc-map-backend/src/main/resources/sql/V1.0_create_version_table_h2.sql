-- 版本 1.0: 创建数据库版本管理表和俱乐部表 (H2兼容版本)
-- 执行时间: 2024-12-XX
-- 描述: 创建用于跟踪数据库迁移版本的表和俱乐部表

-- 创建数据库版本管理表 (H2兼容)
CREATE TABLE IF NOT EXISTS db_version (
    id INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(200),
    sql_file VARCHAR(100) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_time INT,
    status VARCHAR(10) DEFAULT 'SUCCESS',
    error_message TEXT
);

-- 为db_version表创建索引
CREATE INDEX IF NOT EXISTS idx_version ON db_version (version);
CREATE INDEX IF NOT EXISTS idx_executed_at ON db_version (executed_at);

-- 创建俱乐部表 (H2兼容)
CREATE TABLE IF NOT EXISTS club (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(100),
    address VARCHAR(500) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    city VARCHAR(50) NOT NULL,
    meeting_time VARCHAR(200),
    meeting_format VARCHAR(100),
    contact VARCHAR(100),
    contact_phone VARCHAR(50),
    contact_wechat VARCHAR(100),
    features TEXT,
    remarks TEXT,
    status TINYINT NOT NULL DEFAULT 1,
    deleted TINYINT NOT NULL DEFAULT 0,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 为club表创建索引
CREATE INDEX IF NOT EXISTS idx_city ON club (city);
CREATE INDEX IF NOT EXISTS idx_location ON club (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_status ON club (status, deleted);
CREATE INDEX IF NOT EXISTS idx_meeting_time ON club (meeting_time);
CREATE INDEX IF NOT EXISTS idx_city_status ON club (city, status, deleted);

-- 插入初始版本记录
INSERT INTO db_version (version, description, sql_file) VALUES 
('1.0', '创建数据库版本管理表和俱乐部表', 'V1.0_create_version_table_h2.sql'); 