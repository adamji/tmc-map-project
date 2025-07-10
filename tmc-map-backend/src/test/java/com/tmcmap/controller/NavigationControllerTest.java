package com.tmcmap.controller;

import com.tmcmap.model.dto.NavigationDTO;
import com.tmcmap.service.NavigationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ActiveProfiles("test")
@WebMvcTest(NavigationController.class)
class NavigationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NavigationService navigationService;

    @Autowired
    private ObjectMapper objectMapper;

    private NavigationDTO mockNavigation;

    @BeforeEach
    void setUp() {
        mockNavigation = new NavigationDTO();
        mockNavigation.setFromLat(39.9042);
        mockNavigation.setFromLng(116.4074);
        mockNavigation.setToLat(31.2304);
        mockNavigation.setToLng(121.4737);
        mockNavigation.setMode("driving");
        mockNavigation.setDistance(1200000);
        mockNavigation.setDuration(36000);
        mockNavigation.setDescription("从北京到上海的推荐路线");
        mockNavigation.setRoute("路线详情");
    }

    @Test
    void testCalculateRoute() throws Exception {
        // 准备测试数据
        when(navigationService.calculateRoute(anyDouble(), anyDouble(), anyDouble(), anyDouble(), anyString()))
                .thenReturn(mockNavigation);

        NavigationController.NavigationRequest request = new NavigationController.NavigationRequest();
        request.setFromLat(39.9042);
        request.setFromLng(116.4074);
        request.setToLat(31.2304);
        request.setToLng(121.4737);
        request.setMode("driving");

        // 执行测试
        mockMvc.perform(post("/navigation/calculate")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("SUCCESS"))
                .andExpect(jsonPath("$.data.distance").value(1200000))
                .andExpect(jsonPath("$.data.duration").value(36000));
    }

    @Test
    void testCalculateRouteWithInvalidData() throws Exception {
        when(navigationService.calculateRoute(any(), any(), any(), any(), any()))
                .thenThrow(new IllegalArgumentException("无效的坐标参数"));

        NavigationController.NavigationRequest request = new NavigationController.NavigationRequest();
        request.setFromLat(200.0); // 无效纬度
        request.setFromLng(116.4074);
        request.setToLat(31.2304);
        request.setToLng(121.4737);

        mockMvc.perform(post("/navigation/calculate")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testCalculateDistance() throws Exception {
        when(navigationService.calculateDistance(39.9042, 116.4074, 31.2304, 121.4737)).thenReturn(1200000.0);

        mockMvc.perform(get("/navigation/distance")
                .param("fromLat", "39.9042")
                .param("fromLng", "116.4074")
                .param("toLat", "31.2304")
                .param("toLng", "121.4737"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value("SUCCESS"))
                .andExpect(jsonPath("$.data").value(1200000.0));
    }

    @Test
    void testCalculateDistanceWithInvalidParams() throws Exception {
        mockMvc.perform(get("/navigation/distance")
                .param("fromLat", "invalid")
                .param("fromLng", "116.4074")
                .param("toLat", "31.2304")
                .param("toLng", "121.4737"))
                .andExpect(status().isBadRequest());
    }
} 