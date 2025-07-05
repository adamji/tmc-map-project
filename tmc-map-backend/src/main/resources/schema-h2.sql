-- H2数据库初始化脚本

-- 俱乐部表
DROP TABLE IF EXISTS club;
CREATE TABLE club (
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
  update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);

-- 创建索引
CREATE INDEX idx_city ON club(city);
CREATE INDEX idx_location ON club(latitude, longitude);
CREATE INDEX idx_status ON club(status, deleted);
CREATE INDEX idx_meeting_time ON club(meeting_time);
CREATE INDEX idx_city_status ON club(city, status, deleted); 