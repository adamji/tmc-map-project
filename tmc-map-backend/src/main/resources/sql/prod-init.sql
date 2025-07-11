-- 生产环境初始化脚本
-- 适用于MySQL数据库，与Entity类字段完全匹配
-- 包含完整的数据库结构和初始数据

-- 注意：在生产环境中，通常需要手动创建数据库
-- CREATE DATABASE IF NOT EXISTS tmc_map 
-- CHARACTER SET utf8mb4 
-- COLLATE utf8mb4_unicode_ci;
-- USE tmc_map;

-- 创建俱乐部表 (生产环境 - MySQL版本)
CREATE TABLE IF NOT EXISTS club (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    name VARCHAR(200) NOT NULL COMMENT '俱乐部名称',
    english_name VARCHAR(200) COMMENT '俱乐部英文名称',
    short_name VARCHAR(100) COMMENT '俱乐部简称',
    address VARCHAR(500) NOT NULL COMMENT '地址',
    latitude DECIMAL(10,7) COMMENT '纬度',
    longitude DECIMAL(10,7) COMMENT '经度',
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
    INDEX idx_city_status (city, status, deleted),
    INDEX idx_english_name (english_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='头马俱乐部信息表';

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
    INDEX idx_create_time (create_time)
    -- 注意: 暂不添加外键约束，避免部署时的约束冲突
    -- FOREIGN KEY (club_id) REFERENCES club(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='导航记录表';

-- 创建版本管理表 (与DatabaseMigrationService兼容)
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

-- 插入完整的俱乐部数据
INSERT IGNORE INTO club (name, english_name, short_name, address, latitude, longitude, city, meeting_time, meeting_format, contact, contact_phone, contact_wechat, features, remarks, status, deleted) VALUES 
('江宁双语SH俱乐部', 'Jiangning Bilingual Springhead Toastmasters Club', 'SH', '南京市江宁经济技术开发区双龙大道1539号21世纪太阳城小卢可童书馆', 31.9558, 118.842, '南京', '周日 18:30-20:30', '双语', '清思', '18351444832', 'jiqingsi_0114', '外企留学，脱口秀，学习小组', '提高英语提高表达提高领导力首选', 1, 0),
('福特南京俱乐部', 'Ford Nanjing Toastmasters Club', '', '南京市江宁区将军大道118号福特汽车研发中心', NULL, NULL, '南京', '周五11:40-13:00', '企业', '', '', '', '', '', 1, 0),
('CXL俱乐部', 'CXL Toastmasters Club', '', '徐州市金山桥开发区驮蓝山路19号卡特彼勒徐州有限公司', NULL, NULL, '徐州', '周四16:40-18:10', '企业', '', '', '', '', '', 1, 0),
('GPT俱乐部', 'GPT Toastmasters Club', '', '江苏集萃药康生物科技股份有限公司江北新区学府路12号', NULL, NULL, '南京', '周四19:00-21:00', '企业', '', '', '', '', '', 1, 0),
('徐州第一中文俱乐部', 'Xuzhou First Mandarin', '', '徐州市苏宁广场A塔IFC金融中心19A楼AIA', NULL, NULL, '徐州', '周三20:00- 21:40', '线上', '', '', '', '', '', 1, 0),
('南京ET俱乐部', 'Nanjing Student Elite Toastmasters Club', '', '江苏省南京市大行宫长发中心A座908', NULL, NULL, '南京', '周日14:30-17:00', '社区', '', '', '', '', '', 1, 0),
('南京菁英管理俱乐部', 'NJ Elite Management TMC', '', '上海路五星年华大厦1006室', NULL, NULL, '南京', '周日10:00-12:00', '社区', '', '', '', '', '', 1, 0),
('泰康仙林鼓楼俱乐部', 'Taikang Xianlin Drum Tower Toastmasters Club', '', '南京市栖霞区灵山北路188号泰康仙林鼓楼医院二期 开泰楼会议室1', NULL, NULL, '南京', '周五12:00-13:30', '企业', '', '', '', '', '', 1, 0),
('南京职业演讲家俱乐部', 'Nanjing Professional Speaker Advanced Toastmasters Club', '', '上海路五星年华大厦1006室', NULL, NULL, '南京', '周五（隔周）19:15-21：15', '社区', '', '', '', '', '', 1, 0),
('南京SS俱乐部', 'Alcatel-Lucent Smart Speakers Nanjing', '', '大行宫新世纪广场A座811室HR共创空间', NULL, NULL, '南京', '周二19:15-21:00', '社区', '予欣', '18351896875', 'zzyx150402', '', '', 1, 0),
('南京TTT俱乐部', 'Nanjing TTT Toastmasters Club', '', '南京市秦淮区中山东路300号长发中心A座908室', NULL, NULL, '南京', '周日10:00-12:30', '社区', '杨琴', '18115131600', '1290877848', '', '', 1, 0),
('南京自信力俱乐部', 'Nanjing Confidence Toastmasters Club', '', '玄武白马山庄1号楼', NULL, NULL, '南京', '周一19:00-21:00', '社区', '庄莉红', '18651875711', '18651875711', '辩论，国兴，演讲提升', '提高沟通力和领导力，培养自信的演说家', 1, 0),
('合肥No.1俱乐部', 'HeFei No.1 Toastmasters Club', '', '三孝口先锋悦书房', NULL, NULL, '合肥', '周日10:00-12:30', '社区', '', '', '', '', '', 1, 0),
('AACTP合肥俱乐部', 'A.A.C.T.P. HeFei Toastmasters Club', '', '蜀山区华邦大厦A座20层', NULL, NULL, '合肥', '周日10:00-12:20', '社区', '', '', '', '', '', 1, 0),
('飞马合肥俱乐部', 'FeiMa Toastmasters Club', '', '中海原山小区44栋邻聚益家党群服务站', NULL, NULL, '合肥', '周日10:00-12:20', '社区', '', '', '', '', '', 1, 0),
('Xylem A俱乐部', 'Xylem A Toastmasters Club', '', '江苏省南京市六合区经济开发区龙阳路18号', NULL, NULL, '南京', '周一19:00-21:00', '企业', '', '', '', '', '', 1, 0);

-- 记录初始版本
INSERT IGNORE INTO db_version (version, description, sql_file) VALUES 
('1.0', 'Production environment initialization with complete data', 'prod-init.sql'); 