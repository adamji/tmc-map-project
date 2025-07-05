package com.tmcmap.repository.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tmcmap.model.entity.Club;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 俱乐部Mapper接口
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Mapper
public interface ClubMapper extends BaseMapper<Club> {

    /**
     * 根据城市和例会时间查询俱乐部列表
     * 
     * @param city 城市
     * @param weekday 星期几
     * @return 俱乐部列表
     */
    @Select("<script>" +
            "SELECT * FROM club " +
            "WHERE status = 1 AND deleted = 0 " +
            "<if test='city != null and city != \"\"'>" +
            "AND city = #{city} " +
            "</if>" +
            "<if test='weekday != null'>" +
            "AND meeting_time LIKE CONCAT('%', #{weekdayText}, '%') " +
            "</if>" +
            "ORDER BY id ASC" +
            "</script>")
    List<Club> selectByConditions(@Param("city") String city, 
                                  @Param("weekday") Integer weekday,
                                  @Param("weekdayText") String weekdayText);

    /**
     * 根据距离查询附近的俱乐部
     * 
     * @param lat 纬度
     * @param lng 经度
     * @param radius 半径(km)
     * @return 俱乐部列表
     */
    @Select("SELECT *, " +
            "(6371 * acos(cos(radians(#{lat})) * cos(radians(latitude)) * " +
            "cos(radians(longitude) - radians(#{lng})) + " +
            "sin(radians(#{lat})) * sin(radians(latitude)))) AS distance " +
            "FROM club " +
            "WHERE status = 1 AND deleted = 0 " +
            "AND (6371 * acos(cos(radians(#{lat})) * cos(radians(latitude)) * " +
            "cos(radians(longitude) - radians(#{lng})) + " +
            "sin(radians(#{lat})) * sin(radians(latitude)))) <= #{radius} " +
            "ORDER BY distance ASC")
    List<Club> selectNearbyClubs(@Param("lat") Double lat, 
                                 @Param("lng") Double lng, 
                                 @Param("radius") Double radius);
} 