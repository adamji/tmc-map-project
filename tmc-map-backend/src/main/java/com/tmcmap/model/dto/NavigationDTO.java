package com.tmcmap.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 导航信息DTO
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Data
@Schema(description = "导航信息")
public class NavigationDTO {

    @Schema(description = "起点纬度")
    private Double fromLat;

    @Schema(description = "起点经度")
    private Double fromLng;

    @Schema(description = "终点纬度")
    private Double toLat;

    @Schema(description = "终点经度")
    private Double toLng;

    @Schema(description = "出行方式", example = "driving")
    private String mode;

    @Schema(description = "距离(米)")
    private Integer distance;

    @Schema(description = "预计时间(秒)")
    private Integer duration;

    @Schema(description = "路线描述")
    private String description;

    @Schema(description = "推荐路线")
    private String route;
} 