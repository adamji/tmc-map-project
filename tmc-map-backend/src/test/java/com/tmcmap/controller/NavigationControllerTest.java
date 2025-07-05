package com.tmcmap.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tmcmap.model.dto.NavigationDTO;
import com.tmcmap.service.NavigationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

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
    void testCalculateRoute_Success() throws Exception {
        when(navigationService.calculateRoute(anyDouble(), anyDouble(), anyDouble(), anyDouble(), anyString()))
                .thenReturn(mockNavigation);

        String requestJson = "{" +
                "\"fromLat\":39.9042," +
                "\"fromLng\":116.4074," +
                "\"toLat\":31.2304," +
                "\"toLng\":121.4737," +
                "\"mode\":\"driving\"}";

        mockMvc.perform(post("/navigation/calculate")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.fromLat").value(39.9042))
                .andExpect(jsonPath("$.data.toLng").value(121.4737))
                .andExpect(jsonPath("$.data.mode").value("driving"));
    }

    @Test
    void testCalculateRoute_InvalidParam() throws Exception {
        when(navigationService.calculateRoute(any(), any(), any(), any(), any()))
                .thenThrow(new IllegalArgumentException("参数错误"));

        String requestJson = "{" +
                "\"fromLat\":null," +
                "\"fromLng\":null," +
                "\"toLat\":null," +
                "\"toLng\":null," +
                "\"mode\":\"driving\"}";

        mockMvc.perform(post("/navigation/calculate")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400));
    }

    @Test
    void testCalculateDistance_Success() throws Exception {
        when(navigationService.calculateDistance(39.9042, 116.4074, 31.2304, 121.4737)).thenReturn(1200000.0);

        mockMvc.perform(get("/navigation/distance")
                .param("fromLat", "39.9042")
                .param("fromLng", "116.4074")
                .param("toLat", "31.2304")
                .param("toLng", "121.4737"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").value(1200000.0));
    }

    @Test
    void testCalculateDistance_MissingParam() throws Exception {
        mockMvc.perform(get("/navigation/distance")
                .param("fromLat", "39.9042")
                .param("fromLng", "116.4074"))
                .andExpect(status().isBadRequest());
    }
} 