package com.tmcmap.controller;

import com.tmcmap.model.dto.ClubDTO;
import com.tmcmap.model.vo.ApiResponse;
import com.tmcmap.service.ClubService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 俱乐部控制器
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Tag(name = "俱乐部管理", description = "俱乐部相关接口")
@Slf4j
@RestController
@RequestMapping("/clubs")
@RequiredArgsConstructor
public class ClubController {

    private final ClubService clubService;

    @Operation(summary = "获取俱乐部列表", description = "根据条件查询俱乐部列表")
    @GetMapping
    public ApiResponse<List<ClubDTO>> getClubList(
            @Parameter(description = "城市") @RequestParam(required = false) String city,
            @Parameter(description = "星期几(1-7)") @RequestParam(required = false) Integer weekday,
            @Parameter(description = "纬度") @RequestParam(required = false) Double lat,
            @Parameter(description = "经度") @RequestParam(required = false) Double lng) {
        
        log.info("获取俱乐部列表请求，参数：city={}, weekday={}, lat={}, lng={}", 
                city, weekday, lat, lng);
        
        try {
            List<ClubDTO> clubs = clubService.getClubList(city, weekday, lat, lng);
            return ApiResponse.success(clubs);
        } catch (Exception e) {
            log.error("获取俱乐部列表失败", e);
            return ApiResponse.error("获取俱乐部列表失败：" + e.getMessage());
        }
    }

    @Operation(summary = "获取俱乐部详情", description = "根据ID获取俱乐部详细信息")
    @GetMapping("/{id}")
    public ApiResponse<ClubDTO> getClubById(
            @Parameter(description = "俱乐部ID") @PathVariable Long id) {
        
        log.info("获取俱乐部详情请求，ID：{}", id);
        
        try {
            ClubDTO club = clubService.getClubById(id);
            return ApiResponse.success(club);
        } catch (IllegalArgumentException e) {
            log.warn("获取俱乐部详情参数错误：{}", e.getMessage());
            return ApiResponse.error(400, e.getMessage());
        } catch (RuntimeException e) {
            log.error("获取俱乐部详情失败：{}", e.getMessage());
            return ApiResponse.error(404, e.getMessage());
        } catch (Exception e) {
            log.error("获取俱乐部详情异常", e);
            return ApiResponse.error("获取俱乐部详情失败：" + e.getMessage());
        }
    }

    @Operation(summary = "获取附近俱乐部", description = "根据坐标获取附近的俱乐部")
    @GetMapping("/nearby")
    public ApiResponse<List<ClubDTO>> getNearbyClubs(
            @Parameter(description = "纬度", required = true) @RequestParam Double lat,
            @Parameter(description = "经度", required = true) @RequestParam Double lng,
            @Parameter(description = "半径(km)") @RequestParam(defaultValue = "10") Double radius) {
        
        log.info("获取附近俱乐部请求，坐标：{},{}, 半径：{}km", lat, lng, radius);
        
        try {
            List<ClubDTO> clubs = clubService.getNearbyClubs(lat, lng, radius);
            return ApiResponse.success(clubs);
        } catch (IllegalArgumentException e) {
            log.warn("获取附近俱乐部参数错误：{}", e.getMessage());
            return ApiResponse.error(400, e.getMessage());
        } catch (Exception e) {
            log.error("获取附近俱乐部失败", e);
            return ApiResponse.error("获取附近俱乐部失败：" + e.getMessage());
        }
    }
} 