package com.tmcmap.service;

import com.tmcmap.model.dto.ClubDTO;

import java.util.List;

/**
 * 俱乐部业务服务接口
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
public interface ClubService {

    /**
     * 获取俱乐部列表
     * 
     * @param city 城市
     * @param weekday 星期几 (1-7)
     * @param lat 纬度
     * @param lng 经度
     * @return 俱乐部列表
     */
    List<ClubDTO> getClubList(String city, Integer weekday, Double lat, Double lng);

    /**
     * 根据ID获取俱乐部详情
     * 
     * @param id 俱乐部ID
     * @return 俱乐部详情
     */
    ClubDTO getClubById(Long id);

    /**
     * 获取附近的俱乐部
     * 
     * @param lat 纬度
     * @param lng 经度
     * @param radius 半径(km)
     * @return 俱乐部列表
     */
    List<ClubDTO> getNearbyClubs(Double lat, Double lng, Double radius);
} 