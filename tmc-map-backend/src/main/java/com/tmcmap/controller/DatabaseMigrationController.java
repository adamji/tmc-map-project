package com.tmcmap.controller;

import com.tmcmap.service.DatabaseMigrationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 数据库迁移控制器
 * 提供数据库迁移管理API
 */
@RestController
@RequestMapping("/api/migration")
public class DatabaseMigrationController {

    @Autowired
    private DatabaseMigrationService migrationService;

    /**
     * 获取迁移历史
     */
    @GetMapping("/history")
    public Map<String, Object> getMigrationHistory() {
        try {
            List<Map<String, Object>> history = migrationService.getMigrationHistory();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", history);
            response.put("message", "获取迁移历史成功");
            
            return response;
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "获取迁移历史失败: " + e.getMessage());
            return response;
        }
    }

    /**
     * 手动执行迁移
     */
    @PostMapping("/execute")
    public Map<String, Object> executeMigration() {
        try {
            migrationService.executePendingMigrations();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "数据库迁移执行成功");
            
            return response;
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "数据库迁移执行失败: " + e.getMessage());
            return response;
        }
    }

    /**
     * 获取迁移状态
     */
    @GetMapping("/status")
    public Map<String, Object> getMigrationStatus() {
        try {
            List<Map<String, Object>> history = migrationService.getMigrationHistory();
            
            // 统计信息
            long totalMigrations = history.size();
            long successfulMigrations = history.stream()
                .filter(migration -> "SUCCESS".equals(migration.get("status")))
                .count();
            long failedMigrations = totalMigrations - successfulMigrations;
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("data", Map.of(
                "totalMigrations", totalMigrations,
                "successfulMigrations", successfulMigrations,
                "failedMigrations", failedMigrations,
                "lastMigration", history.isEmpty() ? null : history.get(0)
            ));
            response.put("message", "获取迁移状态成功");
            
            return response;
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "获取迁移状态失败: " + e.getMessage());
            return response;
        }
    }
} 