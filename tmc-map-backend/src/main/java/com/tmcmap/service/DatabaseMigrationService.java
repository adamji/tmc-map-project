package com.tmcmap.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 数据库迁移服务
 * 用于自动执行增量SQL更新
 * 支持MySQL和H2数据库
 */
@Service
public class DatabaseMigrationService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private org.springframework.core.io.support.PathMatchingResourcePatternResolver resourceResolver;

    // 版本号正则表达式 - 支持H2特殊版本
    private static final Pattern VERSION_PATTERN = Pattern.compile("V(\\d+\\.\\d+)_(.+?)(?:\\.h2)?\\.sql");

    /**
     * 应用启动时自动执行数据库迁移
     */
    @PostConstruct
    public void migrateOnStartup() {
        try {
            String dbType = getDatabaseType();
            System.out.println("🚀 开始数据库迁移检查... (数据库类型: " + dbType + ")");
            executePendingMigrations();
            System.out.println("✅ 数据库迁移完成");
        } catch (Exception e) {
            System.err.println("❌ 数据库迁移失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 执行待执行的迁移
     */
    public void executePendingMigrations() {
        try {
            // 1. 确保版本表存在
            ensureVersionTableExists();

            // 2. 获取已执行的版本
            Set<String> executedVersions = getExecutedVersions();

            // 3. 获取所有迁移文件
            List<MigrationFile> migrationFiles = getMigrationFiles();

            // 4. 执行未执行的迁移
            for (MigrationFile migrationFile : migrationFiles) {
                if (!executedVersions.contains(migrationFile.version)) {
                    executeMigration(migrationFile);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("数据库迁移失败", e);
        }
    }

    /**
     * 确保版本表存在
     */
    private void ensureVersionTableExists() {
        // 检测数据库类型
        String dbType = getDatabaseType();
        
        String createVersionTable;
        if ("H2".equals(dbType)) {
            // H2兼容版本
            createVersionTable = """
                CREATE TABLE IF NOT EXISTS db_version (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    version VARCHAR(20) NOT NULL UNIQUE,
                    description VARCHAR(200),
                    sql_file VARCHAR(100) NOT NULL,
                    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    execution_time INT,
                    status VARCHAR(10) DEFAULT 'SUCCESS',
                    error_message TEXT
                )
                """;
        } else {
            // MySQL版本
            createVersionTable = """
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
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据库版本管理表'
                """;
        }
        
        jdbcTemplate.execute(createVersionTable);
        
        // 为H2数据库单独创建索引
        if ("H2".equals(dbType)) {
            try {
                jdbcTemplate.execute("CREATE INDEX IF NOT EXISTS idx_version ON db_version (version)");
                jdbcTemplate.execute("CREATE INDEX IF NOT EXISTS idx_executed_at ON db_version (executed_at)");
            } catch (Exception e) {
                // 索引可能已存在，忽略错误
            }
        }
    }
    
    /**
     * 获取数据库类型
     */
    private String getDatabaseType() {
        try {
            String url = jdbcTemplate.getDataSource().getConnection().getMetaData().getURL();
            if (url.contains("h2")) {
                return "H2";
            } else if (url.contains("mysql")) {
                return "MySQL";
            } else {
                return "Unknown";
            }
        } catch (Exception e) {
            return "Unknown";
        }
    }

    /**
     * 获取已执行的版本
     */
    private Set<String> getExecutedVersions() {
        try {
            List<String> versions = jdbcTemplate.queryForList(
                "SELECT version FROM db_version WHERE status = 'SUCCESS'", 
                String.class
            );
            return new HashSet<>(versions);
        } catch (Exception e) {
            // 如果表不存在，返回空集合
            return new HashSet<>();
        }
    }

    /**
     * 获取所有迁移文件 - 根据数据库类型选择合适的文件
     */
    private List<MigrationFile> getMigrationFiles() throws IOException {
        List<MigrationFile> migrationFiles = new ArrayList<>();
        String dbType = getDatabaseType();
        
        System.out.println("🔍 开始扫描迁移文件，数据库类型: " + dbType);
        
        // 获取 sql 目录下的所有文件
        Resource[] resources = resourceResolver.getResources("classpath*:sql/V*.sql");
        System.out.println("📁 找到 " + resources.length + " 个V*.sql文件");
        
        for (Resource resource : resources) {
            String filename = resource.getFilename();
            System.out.println("📄 检查文件: " + filename);
            
            if (filename != null && filename.startsWith("V") && filename.endsWith(".sql")) {
                
                // 根据数据库类型选择合适的文件
                boolean shouldInclude = false;
                if ("H2".equals(dbType)) {
                    // H2优先使用.h2.sql文件，如果不存在则使用.sql文件
                    if (filename.contains(".h2.sql")) {
                        shouldInclude = true;
                        System.out.println("✅ H2文件匹配: " + filename);
                    } else if (!filename.contains(".h2.sql") && !hasH2Version(filename, resources)) {
                        shouldInclude = true;
                        System.out.println("✅ 通用文件匹配(无H2版本): " + filename);
                    } else {
                        System.out.println("❌ 跳过文件(有H2版本): " + filename);
                    }
                } else {
                    // MySQL只使用.sql文件（不包含.h2.sql）
                    shouldInclude = !filename.contains(".h2.sql");
                    System.out.println(shouldInclude ? "✅ MySQL文件匹配: " + filename : "❌ 跳过H2文件: " + filename);
                }
                
                if (shouldInclude) {
                    System.out.println("🔍 检查版本号格式: " + filename);
                    Matcher matcher = VERSION_PATTERN.matcher(filename);
                    if (matcher.matches()) {
                        String version = matcher.group(1);
                        String description = matcher.group(2).replace("_", " ");
                        
                        System.out.println("✅ 版本号匹配: " + version + " - " + description);
                        
                        // 读取SQL内容
                        String sqlContent = StreamUtils.copyToString(
                            resource.getInputStream(), 
                            StandardCharsets.UTF_8
                        );
                        
                        migrationFiles.add(new MigrationFile(version, description, filename, sqlContent));
                        System.out.println("✅ 添加迁移文件: " + filename);
                    } else {
                        System.out.println("❌ 版本号格式不匹配: " + filename + " (期望格式: V1.0_description.sql)");
                    }
                } else {
                    System.out.println("❌ 文件不符合数据库类型要求: " + filename);
                }
            } else {
                System.out.println("❌ 文件名不符合V*.sql格式: " + filename);
            }
        }
        
        // 按版本号排序
        migrationFiles.sort(Comparator.comparing(MigrationFile::getVersion));
        
        System.out.println("📊 最终找到 " + migrationFiles.size() + " 个待执行的迁移文件");
        
        return migrationFiles;
    }
    
    /**
     * 检查是否存在对应的H2版本文件
     */
    private boolean hasH2Version(String filename, Resource[] allResources) {
        String h2Version = filename.replace(".sql", ".h2.sql");
        for (Resource resource : allResources) {
            if (h2Version.equals(resource.getFilename())) {
                return true;
            }
        }
        return false;
    }

    /**
     * 执行单个迁移
     */
    private void executeMigration(MigrationFile migrationFile) {
        long startTime = System.currentTimeMillis();
        String errorMessage = null;
        String status = "SUCCESS";
        
        try {
            System.out.println("📝 执行迁移: " + migrationFile.filename + " (" + migrationFile.description + ")");
            System.out.println("🔍 SQL内容长度: " + migrationFile.sqlContent.length() + " 字符");
            
            // 清理SQL内容，移除注释和空行
            String cleanSql = migrationFile.sqlContent
                .replaceAll("--.*", "")  // 移除单行注释
                .replaceAll("/\\*[\\s\\S]*?\\*/", "")  // 移除多行注释
                .trim();
            
            if (cleanSql.isEmpty()) {
                System.out.println("⚠️  SQL内容为空，跳过执行");
                long executionTime = System.currentTimeMillis() - startTime;
                recordMigrationExecution(migrationFile, status, executionTime, "SQL内容为空");
                return;
            }
            
            System.out.println("🔍 清理后SQL内容: " + cleanSql.substring(0, Math.min(100, cleanSql.length())) + "...");
            
            // 分割SQL语句并执行 - 改进的分割逻辑
            String[] sqlStatements = cleanSql.split(";\\s*(?=\\w)");  // 按分号分割，但保留完整语句
            
            int executedCount = 0;
            for (String sql : sqlStatements) {
                sql = sql.trim();
                if (!sql.isEmpty()) {
                    System.out.println("🚀 执行SQL片段 " + (executedCount + 1) + ": " + 
                        sql.substring(0, Math.min(50, sql.length())) + "...");
                    
                    // 如果SQL不以分号结尾，添加分号
                    if (!sql.endsWith(";")) {
                        sql += ";";
                    }
                    
                    jdbcTemplate.execute(sql);
                    executedCount++;
                }
            }
            
            long executionTime = System.currentTimeMillis() - startTime;
            System.out.println("✅ 迁移成功: " + migrationFile.filename + " (执行了 " + executedCount + " 条SQL，耗时: " + executionTime + "ms)");
            
            // 记录执行结果
            recordMigrationExecution(migrationFile, status, executionTime, errorMessage);
            
        } catch (Exception e) {
            long executionTime = System.currentTimeMillis() - startTime;
            errorMessage = e.getMessage();
            status = "FAILED";
            
            System.err.println("❌ 迁移失败: " + migrationFile.filename + " - " + errorMessage);
            e.printStackTrace();
            
            // 记录执行结果
            recordMigrationExecution(migrationFile, status, executionTime, errorMessage);
            
            throw new RuntimeException("迁移失败: " + migrationFile.filename, e);
        }
    }

    /**
     * 记录迁移执行结果
     */
    private void recordMigrationExecution(MigrationFile migrationFile, String status, long executionTime, String errorMessage) {
        try {
            // 检查是否已经存在该版本的记录
            List<Map<String, Object>> existingRecords = jdbcTemplate.queryForList(
                "SELECT id FROM db_version WHERE version = ?",
                migrationFile.version
            );
            
            if (existingRecords.isEmpty()) {
                // 只有在不存在时才插入新记录
                jdbcTemplate.update(
                    "INSERT INTO db_version (version, description, sql_file, execution_time, status, error_message) VALUES (?, ?, ?, ?, ?, ?)",
                    migrationFile.version,
                    migrationFile.description,
                    migrationFile.filename,
                    executionTime,
                    status,
                    errorMessage
                );
            } else {
                // 如果已存在，则更新状态
                jdbcTemplate.update(
                    "UPDATE db_version SET status = ?, execution_time = ?, error_message = ? WHERE version = ?",
                    status,
                    executionTime,
                    errorMessage,
                    migrationFile.version
                );
            }
        } catch (Exception e) {
            System.err.println("⚠️ 记录迁移执行结果失败: " + e.getMessage());
        }
    }

    /**
     * 获取迁移历史
     */
    public List<Map<String, Object>> getMigrationHistory() {
        return jdbcTemplate.queryForList(
            "SELECT version, description, sql_file, executed_at, execution_time, status, error_message " +
            "FROM db_version ORDER BY executed_at DESC"
        );
    }

    /**
     * 迁移文件信息
     */
    private static class MigrationFile {
        private final String version;
        private final String description;
        private final String filename;
        private final String sqlContent;

        public MigrationFile(String version, String description, String filename, String sqlContent) {
            this.version = version;
            this.description = description;
            this.filename = filename;
            this.sqlContent = sqlContent;
        }

        public String getVersion() {
            return version;
        }
    }
} 