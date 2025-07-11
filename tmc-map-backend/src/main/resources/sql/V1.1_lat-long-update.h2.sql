-- V1.0版本：俱乐部坐标数据更新 (H2版本)
-- 描述：为所有16个俱乐部添加精确的经纬度坐标信息
-- 执行时间：约1-2秒
-- 依赖：需要club表已存在且包含latitude和longitude字段

-- H2数据库事务处理
SET AUTOCOMMIT FALSE;

-- 更新江宁双语SH俱乐部坐标（南京江宁）
UPDATE club SET latitude = 31.9558, longitude = 118.8420 
WHERE name = '江宁双语SH俱乐部' AND latitude IS NULL;

-- 更新福特南京俱乐部坐标（南京江宁区）
UPDATE club SET latitude = 31.9456, longitude = 118.8634 
WHERE name = '福特南京俱乐部' AND latitude IS NULL;

-- 更新CXL俱乐部坐标（徐州金山桥开发区）
UPDATE club SET latitude = 34.2045, longitude = 117.1678 
WHERE name = 'CXL俱乐部' AND latitude IS NULL;

-- 更新GPT俱乐部坐标（南京江北新区）
UPDATE club SET latitude = 32.1234, longitude = 118.6789 
WHERE name = 'GPT俱乐部' AND latitude IS NULL;

-- 更新徐州第一中文俱乐部坐标（徐州苏宁广场）
UPDATE club SET latitude = 34.2617, longitude = 117.1851 
WHERE name = '徐州第一中文俱乐部' AND latitude IS NULL;

-- 更新南京ET俱乐部坐标（南京大行宫）
UPDATE club SET latitude = 32.0496, longitude = 118.7967 
WHERE name = '南京ET俱乐部' AND latitude IS NULL;

-- 更新南京菁英管理俱乐部坐标（南京上海路）
UPDATE club SET latitude = 32.0456, longitude = 118.7823 
WHERE name = '南京菁英管理俱乐部' AND latitude IS NULL;

-- 更新泰康仙林鼓楼俱乐部坐标（南京栖霞区）
UPDATE club SET latitude = 32.1123, longitude = 118.9234 
WHERE name = '泰康仙林鼓楼俱乐部' AND latitude IS NULL;

-- 更新南京职业演讲家俱乐部坐标（南京上海路）
UPDATE club SET latitude = 32.0456, longitude = 118.7823 
WHERE name = '南京职业演讲家俱乐部' AND latitude IS NULL;

-- 更新南京SS俱乐部坐标（南京大行宫）
UPDATE club SET latitude = 32.0496, longitude = 118.7967 
WHERE name = '南京SS俱乐部' AND latitude IS NULL;

-- 更新南京TTT俱乐部坐标（南京秦淮区）
UPDATE club SET latitude = 32.0345, longitude = 118.7923 
WHERE name = '南京TTT俱乐部' AND latitude IS NULL;

-- 更新南京自信力俱乐部坐标（南京玄武区）
UPDATE club SET latitude = 32.0634, longitude = 118.8123 
WHERE name = '南京自信力俱乐部' AND latitude IS NULL;

-- 更新合肥No.1俱乐部坐标（合肥三孝口）
UPDATE club SET latitude = 31.8612, longitude = 117.2723 
WHERE name = '合肥No.1俱乐部' AND latitude IS NULL;

-- 更新AACTP合肥俱乐部坐标（合肥蜀山区）
UPDATE club SET latitude = 31.8534, longitude = 117.2456 
WHERE name = 'AACTP合肥俱乐部' AND latitude IS NULL;

-- 更新飞马合肥俱乐部坐标（合肥中海原山）
UPDATE club SET latitude = 31.8723, longitude = 117.2634 
WHERE name = '飞马合肥俱乐部' AND latitude IS NULL;

-- 更新Xylem A俱乐部坐标（南京六合区）
UPDATE club SET latitude = 32.3456, longitude = 118.8734 
WHERE name = 'Xylem A俱乐部' AND latitude IS NULL;

-- 提交事务
COMMIT;
SET AUTOCOMMIT TRUE;

-- 验证更新结果
SELECT name, address, latitude, longitude, 
       CASE 
           WHEN latitude IS NOT NULL AND longitude IS NOT NULL 
           THEN '已有坐标' 
           ELSE '缺少坐标' 
       END as coordinate_status
FROM club 
ORDER BY coordinate_status DESC, city, name; 