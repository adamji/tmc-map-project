-- 版本 1.1: 创建测试用俱乐部表
-- 执行时间: 2024-12-XX
-- 描述: 创建用于测试的俱乐部表和数据

-- 创建俱乐部表
CREATE TABLE IF NOT EXISTS club (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    short_name VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL,
    lat DECIMAL(10,7) NOT NULL,
    lng DECIMAL(10,7) NOT NULL,
    city VARCHAR(50) NOT NULL,
    meeting_time VARCHAR(100) NOT NULL,
    language VARCHAR(20) DEFAULT '中文',
    contact VARCHAR(50),
    phone VARCHAR(20),
    features VARCHAR(200),
    description TEXT,
    weekday TINYINT NOT NULL,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 注意：测试数据由测试用例单独插入，避免重复 