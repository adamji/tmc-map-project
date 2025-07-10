-- 开发环境初始化脚本 (详细字段版本)
-- 兼容H2数据库，与Entity类字段完全匹配

-- 创建俱乐部表 (开发环境)
DROP TABLE IF EXISTS club;
CREATE TABLE club (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
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
  update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);

-- 创建索引
CREATE INDEX idx_city ON club(city);
CREATE INDEX idx_location ON club(latitude, longitude);
CREATE INDEX idx_status ON club(status, deleted);
CREATE INDEX idx_meeting_time ON club(meeting_time);
CREATE INDEX idx_city_status ON club(city, status, deleted);

-- 插入开发测试数据
INSERT INTO club (name, short_name, address, latitude, longitude, city, meeting_time, meeting_format, contact, contact_phone, contact_wechat, features, remarks) VALUES
('深圳四合院国际演讲俱乐部', '四合院TMC', '深圳市福田区莲花西第一世界广场大厦18A四合院', 22.5431, 114.0579, '深圳', '周一 19:30-21:30', '双语', 'Sherry YANG', '13603014039', 'sherry_wechat', '位于福田中心区，交通便利，双语环境', '欢迎英语爱好者加入'),
('深圳福田国际演讲俱乐部', '福田TMC', '深圳市福田区深南大道6009号NEO大厦A座12楼', 22.5286, 114.0564, '深圳', '周二 19:30-21:30', '双语', 'Jason LI', '13800138001', 'jason_li_wechat', '高端商务环境，国际化氛围', '面向职场精英'),
('深圳南山国际演讲俱乐部', '南山TMC', '深圳市南山区科技园南区虚拟大学园A603', 22.5333, 114.0167, '深圳', '周三 19:30-21:30', '中文', 'Linda CHEN', '13900139001', 'linda_chen_wechat', '科技园区，创新氛围浓厚', '欢迎科技从业者'),
('测试俱乐部1', 'TEST1', '测试地址1', 22.5400, 114.0600, '深圳', '周四 19:30-21:30', '中文', '测试联系人1', '13900000001', 'test_wechat1', '测试特色1', '测试备注1'),
('测试俱乐部2', 'TEST2', '测试地址2', 22.5500, 114.0700, '深圳', '周五 19:30-21:30', '双语', '测试联系人2', '13900000002', 'test_wechat2', '测试特色2', '测试备注2');

-- 创建版本表 (用于数据库迁移)
CREATE TABLE IF NOT EXISTS db_version (
    version VARCHAR(50) PRIMARY KEY COMMENT '版本号',
    description VARCHAR(200) COMMENT '版本描述',
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间'
);

-- 记录初始版本
INSERT INTO db_version (version, description) VALUES 
('DEV_INIT', 'Development environment initialization'); 