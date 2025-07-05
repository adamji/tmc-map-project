package com.tmcmap.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tmcmap.model.dto.ClubDTO;
import com.tmcmap.service.ClubService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * ClubController 单元测试
 */
@WebMvcTest(ClubController.class)
class ClubControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ClubService clubService;

    @Autowired
    private ObjectMapper objectMapper;

    private ClubDTO mockClub;
    private List<ClubDTO> mockClubList;

    @BeforeEach
    void setUp() {
        // 创建测试数据
        mockClub = new ClubDTO();
        mockClub.setId(1L);
        mockClub.setName("北京头马俱乐部");
        mockClub.setCity("北京");
        mockClub.setMeetingTime("19:00");
        mockClub.setLat(39.9042);
        mockClub.setLng(116.4074);
        mockClub.setAddress("北京市朝阳区某某大厦");
        mockClub.setFeatures("专业的演讲与领导力俱乐部");

        mockClubList = Arrays.asList(mockClub);
    }

    @Test
    void testGetClubList_Success() throws Exception {
        // 模拟服务层返回
        when(clubService.getClubList(any(), any(), any(), any())).thenReturn(mockClubList);

        // 执行请求并验证结果
        mockMvc.perform(get("/clubs")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data[0].name").value("北京头马俱乐部"));
    }

    @Test
    void testGetClubList_WithCityFilter() throws Exception {
        // 模拟服务层返回
        when(clubService.getClubList(eq("北京"), any(), any(), any())).thenReturn(mockClubList);

        // 执行请求并验证结果
        mockMvc.perform(get("/clubs")
                .param("city", "北京")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data[0].city").value("北京"));
    }

    @Test
    void testGetClubList_WithWeekdayFilter() throws Exception {
        // 模拟服务层返回
        when(clubService.getClubList(any(), eq(6), any(), any())).thenReturn(mockClubList);

        // 执行请求并验证结果
        mockMvc.perform(get("/clubs")
                .param("weekday", "6")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data[0].meetingTime").value("19:00"));
    }

    @Test
    void testGetClubById_Success() throws Exception {
        // 模拟服务层返回
        when(clubService.getClubById(1L)).thenReturn(mockClub);

        // 执行请求并验证结果
        mockMvc.perform(get("/clubs/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.name").value("北京头马俱乐部"));
    }

    @Test
    void testGetClubById_NotFound() throws Exception {
        // 模拟服务层抛出异常
        when(clubService.getClubById(999L)).thenThrow(new RuntimeException("俱乐部不存在"));

        // 执行请求并验证结果
        mockMvc.perform(get("/clubs/999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(404));
    }

    @Test
    void testGetNearbyClubs_Success() throws Exception {
        // 模拟服务层返回
        when(clubService.getNearbyClubs(39.9042, 116.4074, 10.0)).thenReturn(mockClubList);

        // 执行请求并验证结果
        mockMvc.perform(get("/clubs/nearby")
                .param("lat", "39.9042")
                .param("lng", "116.4074")
                .param("radius", "10")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    void testGetNearbyClubs_InvalidParameters() throws Exception {
        // 执行请求并验证结果（缺少必需参数）
        mockMvc.perform(get("/clubs/nearby")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest());
    }
} 