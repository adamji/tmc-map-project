-- 开发环境初始化脚本
-- 适用于H2数据库，与Entity类字段完全匹配
-- 包含完整的数据库结构和初始数据

-- 创建俱乐部表 (开发环境 - H2兼容版本)
CREATE TABLE IF NOT EXISTS club (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    english_name VARCHAR(200),
    short_name VARCHAR(100),
    address VARCHAR(500) NOT NULL,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
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
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引 (H2兼容)
CREATE INDEX IF NOT EXISTS idx_city ON club (city);
CREATE INDEX IF NOT EXISTS idx_location ON club (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_status ON club (status, deleted);
CREATE INDEX IF NOT EXISTS idx_meeting_time ON club (meeting_time);
CREATE INDEX IF NOT EXISTS idx_city_status ON club (city, status, deleted);
CREATE INDEX IF NOT EXISTS idx_english_name ON club (english_name);

-- 创建导航记录表（可选，用于统计分析）
CREATE TABLE IF NOT EXISTS navigation_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    club_id BIGINT NOT NULL,
    from_latitude DECIMAL(10,7) NOT NULL,
    from_longitude DECIMAL(10,7) NOT NULL,
    to_latitude DECIMAL(10,7) NOT NULL,
    to_longitude DECIMAL(10,7) NOT NULL,
    mode VARCHAR(20) NOT NULL,
    distance INT,
    duration INT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_club_id ON navigation_log (club_id);
CREATE INDEX IF NOT EXISTS idx_create_time ON navigation_log (create_time);

-- 创建版本管理表 (与DatabaseMigrationService兼容)
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

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_version ON db_version (version);
CREATE INDEX IF NOT EXISTS idx_executed_at ON db_version (executed_at);

-- 插入完整的俱乐部数据
INSERT INTO club (name, english_name, short_name, address, latitude, longitude, city, meeting_time, meeting_format, contact, contact_phone, contact_wechat, features, remarks, status, deleted) 
SELECT * FROM (VALUES 
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
('Xylem A俱乐部', 'Xylem A Toastmasters Club', '', '江苏省南京市六合区经济开发区龙阳路18号', NULL, NULL, '南京', '周一19:00-21:00', '企业', '', '', '', '', '', 1, 0)
) AS temp_data(name, english_name, short_name, address, latitude, longitude, city, meeting_time, meeting_format, contact, contact_phone, contact_wechat, features, remarks, status, deleted)
WHERE NOT EXISTS (SELECT 1 FROM club WHERE club.name = temp_data.name);

-- 记录初始版本
INSERT INTO db_version (version, description, sql_file) 
SELECT * FROM (VALUES ('1.0', 'Development environment initialization with complete data', 'dev-init.sql')) AS temp_version(version, description, sql_file)
WHERE NOT EXISTS (SELECT 1 FROM db_version WHERE db_version.version = temp_version.version); 