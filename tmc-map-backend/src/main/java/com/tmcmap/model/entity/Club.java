package com.tmcmap.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 俱乐部实体类
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("club")
public class Club {

    /**
     * 主键ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 俱乐部名称
     */
    @TableField("name")
    private String name;

    /**
     * 俱乐部英文名称
     */
    @TableField("english_name")
    private String englishName;

    /**
     * 俱乐部简称
     */
    @TableField("short_name")
    private String shortName;

    /**
     * 地址
     */
    @TableField("address")
    private String address;

    /**
     * 纬度
     */
    @TableField("latitude")
    private Double latitude;

    /**
     * 经度
     */
    @TableField("longitude")
    private Double longitude;

    /**
     * 城市
     */
    @TableField("city")
    private String city;

    /**
     * 例会时间
     */
    @TableField("meeting_time")
    private String meetingTime;

    /**
     * 会议形式
     */
    @TableField("meeting_format")
    private String meetingFormat;

    /**
     * 联系人
     */
    @TableField("contact")
    private String contact;

    /**
     * 联系电话
     */
    @TableField("contact_phone")
    private String contactPhone;

    /**
     * 联系微信
     */
    @TableField("contact_wechat")
    private String contactWechat;

    /**
     * 俱乐部特色
     */
    @TableField("features")
    private String features;

    /**
     * 备注
     */
    @TableField("remarks")
    private String remarks;

    /**
     * 状态 0-禁用 1-启用
     */
    @TableField("status")
    private Integer status;

    /**
     * 是否删除 0-未删除 1-已删除
     */
    @TableField("deleted")
    private Integer deleted;

    /**
     * 创建时间
     */
    @TableField("create_time")
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField("update_time")
    private LocalDateTime updateTime;
} 