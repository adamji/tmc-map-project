package com.tmcmap.service;

import com.tmcmap.model.dto.NavigationDTO;

/**
 * 导航服务接口
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
public interface NavigationService {
    
    /**
     * 计算两点之间的直线距离
     * 
     * @param fromLat 起点纬度
     * @param fromLng 起点经度
     * @param toLat 终点纬度
     * @param toLng 终点经度
     * @return 距离（米）
     */
    Double calculateDistance(Double fromLat, Double fromLng, Double toLat, Double toLng);
    
    /**
     * 计算导航路线
     * 
     * @param fromLat 起点纬度
     * @param fromLng 起点经度
     * @param toLat 终点纬度
     * @param toLng 终点经度
     * @param mode 导航模式（driving, walking, transit等）
     * @return 导航信息
     */
    NavigationDTO calculateRoute(Double fromLat, Double fromLng, 
                               Double toLat, Double toLng, String mode);
} 