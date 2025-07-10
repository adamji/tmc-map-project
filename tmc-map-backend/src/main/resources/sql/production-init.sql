-- 头马俱乐部地图数据库初始化脚本 (生产环境)
-- 使用前请根据实际情况修改数据库名称和配置

-- 创建数据库
CREATE DATABASE IF NOT EXISTS tmc_map 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE tmc_map;

-- 创建俱乐部表
CREATE TABLE IF NOT EXISTS club (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '俱乐部ID',
    name VARCHAR(100) NOT NULL COMMENT '俱乐部名称',
    short_name VARCHAR(50) NOT NULL COMMENT '简称',
    address VARCHAR(200) NOT NULL COMMENT '地址',
    lat DECIMAL(10,7) NOT NULL COMMENT '纬度',
    lng DECIMAL(10,7) NOT NULL COMMENT '经度',
    city VARCHAR(50) NOT NULL COMMENT '城市',
    meeting_time VARCHAR(100) NOT NULL COMMENT '例会时间',
    language VARCHAR(20) DEFAULT '中文' COMMENT '语言',
    contact VARCHAR(50) COMMENT '联系人',
    phone VARCHAR(20) COMMENT '电话',
    features VARCHAR(200) COMMENT '特色',
    description TEXT COMMENT '描述',
    weekday TINYINT NOT NULL COMMENT '星期几(1-7)',
    status TINYINT DEFAULT 1 COMMENT '状态(1:正常,0:停用)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_city (city),
    INDEX idx_weekday (weekday),
    INDEX idx_status (status),
    INDEX idx_location (lat, lng)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='头马俱乐部信息表';

-- 插入基础数据（请根据实际情况修改）
INSERT INTO club (name, short_name, address, lat, lng, city, meeting_time, language, contact, phone, features, description, weekday, status) VALUES 
('深圳四合院国际演讲俱乐部', '四合院TMC', '深圳市福田区莲花西第一世界广场大厦18A四合院', 22.5431, 114.0579, '深圳', '周一 19:30-21:30 双语', '双语', 'Sherry YANG', '13603014039', '交通便利,环境优雅', '位于福田中心区，交通便利', 1, 1),
('江宁双语SH俱乐部', 'SH', '南京市江宁经济技术开发区双龙大道1539号21世纪太阳城小卢可童书馆', 31.9558, 118.8420, '南京', '周日 18:30-20:30 双语', '双语', ' 清思', '18351444832', '外企留学，脱口秀，学习小组', '提高英语提高表达提高领导力首选', 0, 1);

-- 创建导航记录表（可选，用于统计分析）
CREATE TABLE IF NOT EXISTS navigation_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '导航记录ID',
    club_id BIGINT NOT NULL COMMENT '俱乐部ID',
    from_lat DECIMAL(10,7) NOT NULL COMMENT '起点纬度',
    from_lng DECIMAL(10,7) NOT NULL COMMENT '起点经度',
    to_lat DECIMAL(10,7) NOT NULL COMMENT '终点纬度',
    to_lng DECIMAL(10,7) NOT NULL COMMENT '终点经度',
    mode VARCHAR(20) NOT NULL COMMENT '出行方式',
    distance INT COMMENT '距离(米)',
    duration INT COMMENT '时长(秒)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_club_id (club_id),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (club_id) REFERENCES club(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='导航记录表'; 