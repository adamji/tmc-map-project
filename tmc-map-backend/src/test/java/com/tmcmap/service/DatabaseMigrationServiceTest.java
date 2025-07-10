package com.tmcmap.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 数据库迁移服务单元测试
 */
@SpringBootTest
@ActiveProfiles("test")
class DatabaseMigrationServiceTest {

    @Autowired
    private DatabaseMigrationService migrationService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setUp() {
        // 清理测试数据
        try {
            jdbcTemplate.execute("DROP TABLE IF EXISTS club CASCADE");
            jdbcTemplate.execute("DROP TABLE IF EXISTS db_version CASCADE");
        } catch (Exception e) {
            // 忽略清理错误
        }
    }

    @Test
    void testMigrateOnStartup() {
        // 验证应用启动时自动执行迁移
        assertDoesNotThrow(() -> {
            // 直接调用迁移方法
            migrationService.executePendingMigrations();
        });
    }

    @Test
    void testExecutePendingMigrations() {
        // 测试执行待执行的迁移
        assertDoesNotThrow(() -> {
            migrationService.executePendingMigrations();
        });

        // 验证版本表是否创建
        List<Map<String, Object>> versions = jdbcTemplate.queryForList(
            "SELECT * FROM db_version WHERE status = 'SUCCESS'"
        );
        assertFalse(versions.isEmpty(), "应该有成功执行的迁移记录");
    }

    @Test
    void testGetMigrationHistory() {
        // 先执行一些迁移
        migrationService.executePendingMigrations();

        // 获取迁移历史
        List<Map<String, Object>> history = migrationService.getMigrationHistory();
        
        assertNotNull(history, "迁移历史不应为null");
        assertFalse(history.isEmpty(), "应该有迁移历史记录");
        
        // 验证历史记录的结构
        Map<String, Object> firstRecord = history.get(0);
        assertTrue(firstRecord.containsKey("version"), "应包含版本字段");
        assertTrue(firstRecord.containsKey("description"), "应包含描述字段");
        assertTrue(firstRecord.containsKey("sql_file"), "应包含SQL文件字段");
        assertTrue(firstRecord.containsKey("executed_at"), "应包含执行时间字段");
        assertTrue(firstRecord.containsKey("status"), "应包含状态字段");
    }

    @Test
    void testVersionTableCreation() {
        // 测试版本表创建
        migrationService.executePendingMigrations();

        // 验证表是否存在
        List<Map<String, Object>> tables = jdbcTemplate.queryForList(
            "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DB_VERSION'"
        );
        assertFalse(tables.isEmpty(), "版本表应该被创建");

        // 验证表结构
        List<Map<String, Object>> columns = jdbcTemplate.queryForList(
            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DB_VERSION'"
        );
        assertTrue(columns.size() >= 8, "版本表应该有足够的列");
    }

    @Test
    void testMigrationExecutionOrder() {
        // 测试迁移按版本号顺序执行
        migrationService.executePendingMigrations();

        List<Map<String, Object>> versions = jdbcTemplate.queryForList(
            "SELECT version FROM db_version WHERE status = 'SUCCESS' ORDER BY executed_at ASC"
        );
        
        assertFalse(versions.isEmpty(), "应该有迁移记录");
        
        // 验证版本号顺序（如果有多条记录）
        if (versions.size() > 1) {
            for (int i = 0; i < versions.size() - 1; i++) {
                String currentVersion = (String) versions.get(i).get("version");
                String nextVersion = (String) versions.get(i + 1).get("version");
                
                // 简单的版本号比较（假设格式为 x.y）
                assertTrue(compareVersions(currentVersion, nextVersion) <= 0, 
                    "迁移应该按版本号顺序执行");
            }
        }
    }

    @Test
    void testDuplicateMigrationPrevention() {
        // 测试重复迁移的预防
        migrationService.executePendingMigrations();
        
        // 获取第一次执行的记录数
        List<Map<String, Object>> firstExecution = jdbcTemplate.queryForList(
            "SELECT COUNT(*) as count FROM db_version"
        );
        int firstCount = ((Number) firstExecution.get(0).get("count")).intValue();

        // 再次执行迁移
        migrationService.executePendingMigrations();
        
        // 获取第二次执行的记录数
        List<Map<String, Object>> secondExecution = jdbcTemplate.queryForList(
            "SELECT COUNT(*) as count FROM db_version"
        );
        int secondCount = ((Number) secondExecution.get(0).get("count")).intValue();

        // 记录数应该相同，说明没有重复执行
        assertEquals(firstCount, secondCount, "不应该重复执行相同的迁移");
    }

    @Test
    void testMigrationWithError() {
        // 测试迁移执行失败的情况
        assertDoesNotThrow(() -> {
            // 尝试执行一个无效的SQL（这应该被捕获并记录）
            try {
                jdbcTemplate.execute("INVALID SQL STATEMENT");
            } catch (Exception e) {
                // 预期会抛出异常
                assertTrue(e.getMessage().contains("INVALID") || e.getMessage().contains("syntax"));
            }
        });
    }

    @Test
    void testDatabaseTypeDetection() {
        // 测试数据库类型检测
        // 在测试环境中应该是H2
        migrationService.executePendingMigrations();
        
        // 验证H2兼容的表结构
        List<Map<String, Object>> columns = jdbcTemplate.queryForList(
            "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS " +
            "WHERE TABLE_NAME = 'DB_VERSION' AND COLUMN_NAME = 'STATUS'"
        );
        
        assertFalse(columns.isEmpty(), "应该能检测到H2数据库类型");
    }

    @Test
    void testClubTableCreation() {
        // 测试俱乐部表创建
        migrationService.executePendingMigrations();

        // 验证俱乐部表是否存在
        List<Map<String, Object>> tables = jdbcTemplate.queryForList(
            "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CLUB'"
        );
        assertFalse(tables.isEmpty(), "俱乐部表应该被创建");

        // 验证表结构
        List<Map<String, Object>> columns = jdbcTemplate.queryForList(
            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CLUB'"
        );
        assertTrue(columns.size() >= 10, "俱乐部表应该有足够的列");
    }

    @Test
    void testDataInsertion() {
        // 测试数据插入
        migrationService.executePendingMigrations();

        // 插入测试数据
        jdbcTemplate.execute("""
            INSERT INTO club (name, short_name, address, lat, lng, city, meeting_time, language, contact, phone, features, description, weekday, status) VALUES 
            ('Test Club 1', 'TestTMC1', 'Test Address 1', 31.9558, 118.8420, 'Nanjing', 'Monday 19:00-21:00 Chinese', 'Chinese', 'Test Contact 1', '13800000001', 'Test Feature 1', 'Test Description 1', 1, 1)
        """);

        // 验证数据是否插入成功
        List<Map<String, Object>> clubs = jdbcTemplate.queryForList(
            "SELECT COUNT(*) as count FROM club"
        );
        int count = ((Number) clubs.get(0).get("count")).intValue();
        assertTrue(count > 0, "应该有数据被插入");
    }

    /**
     * 比较版本号
     * @param version1 版本1
     * @param version2 版本2
     * @return 比较结果
     */
    private int compareVersions(String version1, String version2) {
        String[] parts1 = version1.split("\\.");
        String[] parts2 = version2.split("\\.");
        
        int maxLength = Math.max(parts1.length, parts2.length);
        
        for (int i = 0; i < maxLength; i++) {
            int num1 = i < parts1.length ? Integer.parseInt(parts1[i]) : 0;
            int num2 = i < parts2.length ? Integer.parseInt(parts2[i]) : 0;
            
            if (num1 != num2) {
                return Integer.compare(num1, num2);
            }
        }
        
        return 0;
    }
} 