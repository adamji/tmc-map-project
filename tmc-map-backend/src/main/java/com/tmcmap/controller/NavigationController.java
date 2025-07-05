package com.tmcmap.controller;

import com.tmcmap.model.dto.NavigationDTO;
import com.tmcmap.model.vo.ApiResponse;
import com.tmcmap.service.NavigationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 导航控制器
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Tag(name = "导航服务", description = "导航路线计算相关接口")
@Slf4j
@RestController
@RequestMapping("/navigation")
@RequiredArgsConstructor
public class NavigationController {

    private final NavigationService navigationService;

    @Operation(summary = "计算导航路线", description = "根据起终点坐标计算导航路线信息")
    @PostMapping("/calculate")
    public ApiResponse<NavigationDTO> calculateRoute(@RequestBody NavigationRequest request) {
        log.info("计算导航路线请求：{}", request);
        
        try {
            NavigationDTO navigation = navigationService.calculateRoute(
                    request.getFromLat(), request.getFromLng(),
                    request.getToLat(), request.getToLng(),
                    request.getMode());
            
            return ApiResponse.success(navigation);
        } catch (IllegalArgumentException e) {
            log.warn("计算导航路线参数错误：{}", e.getMessage());
            return ApiResponse.error(400, e.getMessage());
        } catch (Exception e) {
            log.error("计算导航路线失败", e);
            return ApiResponse.error("计算导航路线失败：" + e.getMessage());
        }
    }

    @Operation(summary = "计算距离", description = "计算两点间的直线距离")
    @GetMapping("/distance")
    public ApiResponse<Double> calculateDistance(
            @Parameter(description = "起点纬度", required = true) @RequestParam Double fromLat,
            @Parameter(description = "起点经度", required = true) @RequestParam Double fromLng,
            @Parameter(description = "终点纬度", required = true) @RequestParam Double toLat,
            @Parameter(description = "终点经度", required = true) @RequestParam Double toLng) {
        
        log.info("计算距离请求，起点：{},{}, 终点：{},{}", fromLat, fromLng, toLat, toLng);
        
        try {
            Double distance = navigationService.calculateDistance(fromLat, fromLng, toLat, toLng);
            return ApiResponse.success(distance);
        } catch (IllegalArgumentException e) {
            log.warn("计算距离参数错误：{}", e.getMessage());
            return ApiResponse.error(400, e.getMessage());
        } catch (Exception e) {
            log.error("计算距离失败", e);
            return ApiResponse.error("计算距离失败：" + e.getMessage());
        }
    }

    /**
     * 导航请求参数
     */
    @lombok.Data
    public static class NavigationRequest {
        @Parameter(description = "起点纬度", required = true)
        private Double fromLat;
        
        @Parameter(description = "起点经度", required = true)
        private Double fromLng;
        
        @Parameter(description = "终点纬度", required = true)
        private Double toLat;
        
        @Parameter(description = "终点经度", required = true)
        private Double toLng;
        
        @Parameter(description = "出行方式", example = "driving")
        private String mode = "driving";
    }
} 