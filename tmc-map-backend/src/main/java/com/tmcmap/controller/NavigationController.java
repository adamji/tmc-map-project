package com.tmcmap.controller;

import com.tmcmap.model.dto.NavigationDTO;
import com.tmcmap.model.vo.ApiResponse;
import com.tmcmap.service.NavigationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

@Slf4j
@RestController
@RequestMapping("/navigation")
@RequiredArgsConstructor
@Tag(name = "导航管理", description = "导航路线计算相关接口")
public class NavigationController {

    private final NavigationService navigationService;

    @PostMapping("/calculate")
    @Operation(summary = "计算导航路线", description = "根据起点终点计算导航路线")
    public ApiResponse<NavigationDTO> calculateRoute(@RequestBody @Valid NavigationRequest request) {
        log.info("计算导航路线请求：起点({}, {}), 终点({}, {}), 模式: {}", 
                request.getFromLat(), request.getFromLng(), request.getToLat(), request.getToLng(), request.getMode());
        
        NavigationDTO navigation = navigationService.calculateRoute(
                request.getFromLat(), request.getFromLng(),
                request.getToLat(), request.getToLng(),
                request.getMode()
        );
        
        return ApiResponse.success(navigation);
    }

    @GetMapping("/distance")
    @Operation(summary = "计算两点直线距离", description = "计算两个地理坐标点之间的直线距离")
    public ApiResponse<Double> calculateDistance(
            @Parameter(description = "起点纬度") @RequestParam @NotNull 
            @DecimalMin(value = "-90", message = "纬度必须在-90到90之间") 
            @DecimalMax(value = "90", message = "纬度必须在-90到90之间") Double fromLat,
            
            @Parameter(description = "起点经度") @RequestParam @NotNull 
            @DecimalMin(value = "-180", message = "经度必须在-180到180之间") 
            @DecimalMax(value = "180", message = "经度必须在-180到180之间") Double fromLng,
            
            @Parameter(description = "终点纬度") @RequestParam @NotNull 
            @DecimalMin(value = "-90", message = "纬度必须在-90到90之间") 
            @DecimalMax(value = "90", message = "纬度必须在-90到90之间") Double toLat,
            
            @Parameter(description = "终点经度") @RequestParam @NotNull 
            @DecimalMin(value = "-180", message = "经度必须在-180到180之间") 
            @DecimalMax(value = "180", message = "经度必须在-180到180之间") Double toLng) {
        
        log.info("计算直线距离请求：起点({}, {}), 终点({}, {})", fromLat, fromLng, toLat, toLng);
        
        Double distance = navigationService.calculateDistance(fromLat, fromLng, toLat, toLng);
        
        return ApiResponse.success(distance);
    }

    @Data
    @Validated
    public static class NavigationRequest {
        @NotNull(message = "起点纬度不能为空")
        @DecimalMin(value = "-90", message = "纬度必须在-90到90之间")
        @DecimalMax(value = "90", message = "纬度必须在-90到90之间")
        private Double fromLat;

        @NotNull(message = "起点经度不能为空")
        @DecimalMin(value = "-180", message = "经度必须在-180到180之间")
        @DecimalMax(value = "180", message = "经度必须在-180到180之间")
        private Double fromLng;

        @NotNull(message = "终点纬度不能为空")
        @DecimalMin(value = "-90", message = "纬度必须在-90到90之间")
        @DecimalMax(value = "90", message = "纬度必须在-90到90之间")
        private Double toLat;

        @NotNull(message = "终点经度不能为空")
        @DecimalMin(value = "-180", message = "经度必须在-180到180之间")
        @DecimalMax(value = "180", message = "经度必须在-180到180之间")
        private Double toLng;

        private String mode = "driving"; // 默认驾车模式
    }
} 