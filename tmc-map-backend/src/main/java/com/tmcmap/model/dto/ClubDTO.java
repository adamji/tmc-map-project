package com.tmcmap.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 俱乐部DTO
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Data
@Schema(description = "俱乐部信息")
public class ClubDTO {

    @Schema(description = "俱乐部ID")
    private Long id;

    @Schema(description = "俱乐部名称")
    private String name;

    @Schema(description = "俱乐部简称")
    private String shortName;

    @Schema(description = "地址")
    private String address;

    @Schema(description = "纬度")
    private Double lat;

    @Schema(description = "经度")
    private Double lng;

    @Schema(description = "城市")
    private String city;

    @Schema(description = "例会时间")
    private String meetingTime;

    @Schema(description = "会议形式")
    private String meetingFormat;

    @Schema(description = "联系人")
    private String contact;

    @Schema(description = "联系电话")
    private String contactPhone;

    @Schema(description = "联系微信")
    private String contactWechat;

    @Schema(description = "俱乐部特色")
    private String features;

    @Schema(description = "备注")
    private String remarks;
} 