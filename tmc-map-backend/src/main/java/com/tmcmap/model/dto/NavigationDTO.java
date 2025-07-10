package com.tmcmap.model.dto;

import lombok.Data;

/**
 * 导航信息数据传输对象
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Data
public class NavigationDTO {
    
    /**
     * 起点纬度
     */
    private Double fromLat;
    
    /**
     * 起点经度
     */
    private Double fromLng;
    
    /**
     * 终点纬度
     */
    private Double toLat;
    
    /**
     * 终点经度
     */
    private Double toLng;
    
    /**
     * 导航模式
     */
    private String mode;
    
    /**
     * 距离（米）
     */
    private Integer distance;
    
    /**
     * 预计时长（秒）
     */
    private Integer duration;
    
    /**
     * 路线描述
     */
    private String description;
    
    /**
     * 详细路线信息
     */
    private String route;
} 