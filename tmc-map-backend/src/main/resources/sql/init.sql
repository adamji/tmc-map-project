-- 头马俱乐部地图数据库初始化脚本

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `tmc_map` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `tmc_map`;

-- 俱乐部表
DROP TABLE IF EXISTS `club`;
CREATE TABLE `club` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(200) NOT NULL COMMENT '俱乐部名称',
  `short_name` varchar(100) DEFAULT NULL COMMENT '俱乐部简称',
  `address` varchar(500) NOT NULL COMMENT '地址',
  `latitude` decimal(10,7) NOT NULL COMMENT '纬度',
  `longitude` decimal(10,7) NOT NULL COMMENT '经度',
  `city` varchar(50) NOT NULL COMMENT '城市',
  `meeting_time` varchar(200) DEFAULT NULL COMMENT '例会时间',
  `meeting_format` varchar(100) DEFAULT NULL COMMENT '会议形式',
  `contact` varchar(100) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(50) DEFAULT NULL COMMENT '联系电话',
  `contact_wechat` varchar(100) DEFAULT NULL COMMENT '联系微信',
  `features` text COMMENT '俱乐部特色',
  `remarks` text COMMENT '备注',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态 0-禁用 1-启用',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否删除 0-未删除 1-已删除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_city` (`city`),
  KEY `idx_location` (`latitude`,`longitude`),
  KEY `idx_status` (`status`,`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='俱乐部表';

-- 插入示例数据
INSERT INTO `club` (`name`, `short_name`, `address`, `latitude`, `longitude`, `city`, `meeting_time`, `meeting_format`, `contact`, `contact_phone`, `contact_wechat`, `features`, `remarks`) VALUES
('深圳四合院国际演讲俱乐部', '四合院TMC', '深圳市福田区莲花西第一世界广场大厦18A四合院', 22.5431, 114.0579, '深圳', '周一 19:30-21:30 双语', '双语', 'Sherry YANG', '13603014039', NULL, '位于福田中心区，交通便利，双语环境', '欢迎英语爱好者加入'),
('深圳福田国际演讲俱乐部', '福田TMC', '深圳市福田区深南大道6009号NEO大厦A座12楼', 22.5286, 114.0564, '深圳', '周二 19:30-21:30 双语', '双语', 'Jason LI', '13800138001', NULL, '高端商务环境，国际化氛围', '面向职场精英'),
('深圳南山国际演讲俱乐部', '南山TMC', '深圳市南山区科技园南区虚拟大学园A603', 22.5333, 114.0167, '深圳', '周三 19:30-21:30 中文', '中文', 'Linda CHEN', '13900139001', NULL, '科技园区，创新氛围浓厚', '欢迎科技从业者'),
('深圳宝安国际演讲俱乐部', '宝安TMC', '深圳市宝安区新安街道创业二路新一佳商务大厦B座802', 22.5564, 113.8247, '深圳', '周四 19:30-21:30 中文', '中文', 'David WANG', '13700137001', NULL, '宝安区唯一头马俱乐部', '服务宝安地区会员'),
('深圳龙华国际演讲俱乐部', '龙华TMC', '深圳市龙华区民治街道民康路1号龙华商务中心B座1208', 22.6542, 114.0317, '深圳', '周五 19:30-21:30 双语', '双语', 'Emily ZHOU', '13600136001', NULL, '龙华新区，新兴商务区', '年轻活力的俱乐部'),
('广州天河国际演讲俱乐部', '天河TMC', '广州市天河区天河路208号粤海天河城大厦4001', 23.1350, 113.3261, '广州', '周六 14:30-16:30 双语', '双语', 'Michael HUANG', '13500135001', NULL, '天河CBD核心地段', '周末聚会，轻松氛围'),
('广州越秀国际演讲俱乐部', '越秀TMC', '广州市越秀区中山五路219号中旅商业城东塔18楼', 23.1291, 113.2644, '广州', '周日 14:30-16:30 中文', '中文', 'Grace LIU', '13400134001', NULL, '历史悠久的越秀区', '传统与现代结合'),
('上海浦东国际演讲俱乐部', '浦东TMC', '上海市浦东新区陆家嘴环路1000号恒生银行大厦3楼', 31.2351, 121.5035, '上海', '周一 19:00-21:00 双语', '双语', 'Kevin ZHANG', '13300133001', NULL, '陆家嘴金融区', '国际金融精英聚集地'),
('上海静安国际演讲俱乐部', '静安TMC', '上海市静安区南京西路1376号上海商城东峰540室', 31.2322, 121.4554, '上海', '周三 19:00-21:00 中文', '中文', 'Anna SONG', '13200132001', NULL, '南京西路商圈', '优雅商务环境'),
('北京朝阳国际演讲俱乐部', '朝阳TMC', '北京市朝阳区建国门外大街1号国贸三期B座55层', 39.9097, 116.4589, '北京', '周二 19:00-21:00 双语', '双语', 'Tony WANG', '13100131001', NULL, 'CBD核心区域', '首都商务精英俱乐部');

-- 创建索引优化查询性能
CREATE INDEX idx_meeting_time ON club(meeting_time);
CREATE INDEX idx_city_status ON club(city, status, deleted); 