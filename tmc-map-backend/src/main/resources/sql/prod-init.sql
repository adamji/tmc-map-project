-- 生产环境初始化脚本 (统一详细字段版本)
-- 适用于MySQL数据库，与Entity类字段完全匹配

-- 注意：在生产环境中，通常需要手动创建数据库
-- CREATE DATABASE IF NOT EXISTS tmc_map 
-- CHARACTER SET utf8mb4 
-- COLLATE utf8mb4_unicode_ci;
-- USE tmc_map;

-- 创建俱乐部表 (生产环境 - 统一使用详细字段名)
CREATE TABLE IF NOT EXISTS club (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    name VARCHAR(200) NOT NULL COMMENT '俱乐部名称',
    short_name VARCHAR(100) COMMENT '俱乐部简称',
    address VARCHAR(500) NOT NULL COMMENT '地址',
    latitude DECIMAL(10,7) NOT NULL COMMENT '纬度',
    longitude DECIMAL(10,7) NOT NULL COMMENT '经度',
    city VARCHAR(50) NOT NULL COMMENT '城市',
    meeting_time VARCHAR(200) COMMENT '例会时间',
    meeting_format VARCHAR(100) COMMENT '会议形式',
    contact VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(50) COMMENT '联系电话',
    contact_wechat VARCHAR(100) COMMENT '联系微信',
    features TEXT COMMENT '俱乐部特色',
    remarks TEXT COMMENT '备注',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态 0-禁用 1-启用',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除 0-未删除 1-已删除',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_city (city),
    INDEX idx_location (latitude, longitude),
    INDEX idx_status (status, deleted),
    INDEX idx_meeting_time (meeting_time),
    INDEX idx_city_status (city, status, deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='头马俱乐部信息表';

-- 插入生产基础数据

INSERT INTO club (name, short_name, address, latitude, longitude, city, meeting_time, meeting_format, contact, contact_phone, contact_wechat, features, remarks) VALUES 
('深圳四合院国际演讲俱乐部', '四合院TMC', '深圳市福田区莲花西第一世界广场大厦18A四合院', 22.5431, 114.0579, '深圳', '周一 19:30-21:30', '双语', 'Sherry YANG', '13603014039', 'sherry_yang_wechat', '位于福田中心区，交通便利，双语环境', '欢迎英语爱好者加入'),
('江宁双语SH俱乐部', 'SH', '南京市江宁经济技术开发区双龙大道1539号21世纪太阳城小卢可童书馆', 31.9558, 118.8420, '南京', '周日 18:30-20:30', '双语', '清思', '18351444832', 'qingsi_wechat', '外企留学，脱口秀，学习小组', '提高英语提高表达提高领导力首选'),
('广州天河国际演讲俱乐部', '天河TMC', '广州市天河区天河路208号粤海天河城大厦4001', 23.1350, 113.3261, '广州', '周六 14:30-16:30', '双语', 'Michael HUANG', '13500135001', 'michael_huang_wechat', '天河CBD核心地段', '周末聚会，轻松氛围'),
('上海浦东国际演讲俱乐部', '浦东TMC', '上海市浦东新区陆家嘴环路1000号恒生银行大厦3楼', 31.2351, 121.5035, '上海', '周一 19:00-21:00', '双语', 'Kevin ZHANG', '13300133001', 'kevin_zhang_wechat', '陆家嘴金融区', '国际金融精英聚集地'),
('北京朝阳国际演讲俱乐部', '朝阳TMC', '北京市朝阳区建国门外大街1号国贸三期B座55层', 39.9097, 116.4589, '北京', '周二 19:00-21:00', '双语', 'Tony WANG', '13100131001', 'tony_wang_wechat', 'CBD核心区域', '首都商务精英俱乐部');

-- 创建导航记录表（可选，用于统计分析）
CREATE TABLE IF NOT EXISTS navigation_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '导航记录ID',
    club_id BIGINT NOT NULL COMMENT '俱乐部ID',
    from_latitude DECIMAL(10,7) NOT NULL COMMENT '起点纬度',
    from_longitude DECIMAL(10,7) NOT NULL COMMENT '起点经度',
    to_latitude DECIMAL(10,7) NOT NULL COMMENT '终点纬度',
    to_longitude DECIMAL(10,7) NOT NULL COMMENT '终点经度',
    mode VARCHAR(20) NOT NULL COMMENT '出行方式',
    distance INT COMMENT '距离(米)',
    duration INT COMMENT '时长(秒)',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_club_id (club_id),
    INDEX idx_create_time (create_time),
    FOREIGN KEY (club_id) REFERENCES club(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='导航记录表';

-- 创建版本表 (用于数据库迁移)
CREATE TABLE IF NOT EXISTS db_version (
    version VARCHAR(50) PRIMARY KEY COMMENT '版本号',
    description VARCHAR(200) COMMENT '版本描述',
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据库版本管理表';

-- 记录初始版本
INSERT INTO db_version (version, description) VALUES 
('PROD_INIT', 'Production environment initialization'); 