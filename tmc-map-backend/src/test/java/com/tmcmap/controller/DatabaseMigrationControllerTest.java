package com.tmcmap.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 数据库迁移控制器单元测试
 */
@SpringBootTest
@AutoConfigureWebMvc
@ActiveProfiles("test")
@Transactional
class DatabaseMigrationControllerTest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        
        // 清理测试数据
        jdbcTemplate.execute("DROP TABLE IF EXISTS db_version");
        jdbcTemplate.execute("DROP TABLE IF EXISTS club");
    }

    @Test
    void testGetMigrationHistory() throws Exception {
        // 测试获取迁移历史
        mockMvc.perform(get("/api/migration/history"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").exists())
                .andExpect(jsonPath("$.message").value("获取迁移历史成功"));
    }

    @Test
    void testGetMigrationStatus() throws Exception {
        // 测试获取迁移状态
        mockMvc.perform(get("/api/migration/status"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").exists())
                .andExpect(jsonPath("$.data.totalMigrations").exists())
                .andExpect(jsonPath("$.data.successfulMigrations").exists())
                .andExpect(jsonPath("$.data.failedMigrations").exists())
                .andExpect(jsonPath("$.message").value("获取迁移状态成功"));
    }

    @Test
    void testExecuteMigration() throws Exception {
        // 测试手动执行迁移
        mockMvc.perform(post("/api/migration/execute"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("数据库迁移执行成功"));
    }

    @Test
    void testMigrationHistoryStructure() throws Exception {
        // 测试迁移历史的数据结构
        String response = mockMvc.perform(get("/api/migration/history"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Map<String, Object> responseMap = objectMapper.readValue(response, Map.class);
        
        assertTrue(responseMap.containsKey("success"));
        assertTrue(responseMap.containsKey("data"));
        assertTrue(responseMap.containsKey("message"));
        
        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) responseMap.get("data");
        assertNotNull(data);
    }

    @Test
    void testMigrationStatusStructure() throws Exception {
        // 测试迁移状态的数据结构
        String response = mockMvc.perform(get("/api/migration/status"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Map<String, Object> responseMap = objectMapper.readValue(response, Map.class);
        
        assertTrue(responseMap.containsKey("success"));
        assertTrue(responseMap.containsKey("data"));
        assertTrue(responseMap.containsKey("message"));
        
        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) responseMap.get("data");
        assertNotNull(data);
        assertTrue(data.containsKey("totalMigrations"));
        assertTrue(data.containsKey("successfulMigrations"));
        assertTrue(data.containsKey("failedMigrations"));
    }

    @Test
    void testExecuteMigrationWithData() throws Exception {
        // 测试执行迁移后数据的变化
        // 先获取初始状态
        String initialResponse = mockMvc.perform(get("/api/migration/status"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Map<String, Object> initialData = objectMapper.readValue(initialResponse, Map.class);
        @SuppressWarnings("unchecked")
        Map<String, Object> initialStatus = (Map<String, Object>) initialData.get("data");
        int initialTotal = ((Number) initialStatus.get("totalMigrations")).intValue();

        // 执行迁移
        mockMvc.perform(post("/api/migration/execute"))
                .andExpect(status().isOk());

        // 再次获取状态
        String finalResponse = mockMvc.perform(get("/api/migration/status"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Map<String, Object> finalData = objectMapper.readValue(finalResponse, Map.class);
        @SuppressWarnings("unchecked")
        Map<String, Object> finalStatus = (Map<String, Object>) finalData.get("data");
        int finalTotal = ((Number) finalStatus.get("totalMigrations")).intValue();

        // 验证迁移执行后记录数增加
        assertTrue(finalTotal >= initialTotal, "执行迁移后记录数应该增加或保持不变");
    }

    @Test
    void testErrorHandling() throws Exception {
        // 测试错误处理
        // 这里我们通过删除表来模拟错误情况
        jdbcTemplate.execute("DROP TABLE IF EXISTS db_version");
        
        // 即使表不存在，API也应该正常响应
        mockMvc.perform(get("/api/migration/history"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").exists());
    }

    @Test
    void testApiEndpointsExist() throws Exception {
        // 测试API端点是否存在
        mockMvc.perform(get("/api/migration/history"))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/migration/status"))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/migration/execute"))
                .andExpect(status().isOk());
    }

    @Test
    void testResponseContentType() throws Exception {
        // 测试响应内容类型
        mockMvc.perform(get("/api/migration/history"))
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));

        mockMvc.perform(get("/api/migration/status"))
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));

        mockMvc.perform(post("/api/migration/execute"))
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }

    @Test
    void testMigrationHistoryAfterExecution() throws Exception {
        // 测试执行迁移后历史记录的变化
        // 获取初始历史
        String initialHistory = mockMvc.perform(get("/api/migration/history"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Map<String, Object> initialData = objectMapper.readValue(initialHistory, Map.class);
        @SuppressWarnings("unchecked")
        java.util.List<Map<String, Object>> initialHistoryList = 
            (java.util.List<Map<String, Object>>) initialData.get("data");
        int initialSize = initialHistoryList.size();

        // 执行迁移
        mockMvc.perform(post("/api/migration/execute"))
                .andExpect(status().isOk());

        // 获取最终历史
        String finalHistory = mockMvc.perform(get("/api/migration/history"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Map<String, Object> finalData = objectMapper.readValue(finalHistory, Map.class);
        @SuppressWarnings("unchecked")
        java.util.List<Map<String, Object>> finalHistoryList = 
            (java.util.List<Map<String, Object>>) finalData.get("data");
        int finalSize = finalHistoryList.size();

        // 验证历史记录数量变化
        assertTrue(finalSize >= initialSize, "执行迁移后历史记录应该增加或保持不变");
    }
} 