package com.tmcmap.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tmcmap.model.dto.ClubDTO;
import com.tmcmap.model.entity.Club;
import com.tmcmap.repository.mapper.ClubMapper;
import com.tmcmap.service.ClubService;
import com.tmcmap.util.ClubConverter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 俱乐部业务服务实现类
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ClubServiceImpl implements ClubService {

    private final ClubMapper clubMapper;
    private final ClubConverter clubConverter;

    /**
     * 星期映射
     */
    private static final Map<Integer, String> WEEKDAY_MAP = new HashMap<>();
    
    static {
        WEEKDAY_MAP.put(1, "周一");
        WEEKDAY_MAP.put(2, "周二");
        WEEKDAY_MAP.put(3, "周三");
        WEEKDAY_MAP.put(4, "周四");
        WEEKDAY_MAP.put(5, "周五");
        WEEKDAY_MAP.put(6, "周六");
        WEEKDAY_MAP.put(7, "周日");
    }

    @Override
    public List<ClubDTO> getClubList(String city, Integer weekday, Double lat, Double lng) {
        log.info("获取俱乐部列表，城市：{}，星期：{}，坐标：{},{}", city, weekday, lat, lng);
        
        List<Club> clubs;
        
        // 如果有经纬度坐标，优先使用附近查询
        if (lat != null && lng != null) {
            // 默认查询半径50km
            clubs = clubMapper.selectNearbyClubs(lat, lng, 50.0);
            
            // 如果有星期筛选，进一步过滤
            if (weekday != null && WEEKDAY_MAP.containsKey(weekday)) {
                String weekdayText = WEEKDAY_MAP.get(weekday);
                clubs = clubs.stream()
                        .filter(club -> club.getMeetingTime() != null && 
                                       club.getMeetingTime().contains(weekdayText))
                        .collect(Collectors.toList());
            }
        } else {
            // 根据城市和星期查询
            String weekdayText = weekday != null ? WEEKDAY_MAP.get(weekday) : null;
            clubs = clubMapper.selectByConditions(city, weekday, weekdayText);
        }
        
        log.info("查询到{}个俱乐部", clubs.size());
        return clubs.stream()
                .map(clubConverter::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    public ClubDTO getClubById(Long id) {
        log.info("获取俱乐部详情，ID：{}", id);
        
        if (id == null) {
            throw new IllegalArgumentException("俱乐部ID不能为空");
        }
        
        LambdaQueryWrapper<Club> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Club::getId, id)
               .eq(Club::getStatus, 1)
               .eq(Club::getDeleted, 0);
        
        Club club = clubMapper.selectOne(wrapper);
        if (club == null) {
            throw new RuntimeException("俱乐部不存在或已被删除");
        }
        
        return clubConverter.toDTO(club);
    }

    @Override
    public List<ClubDTO> getNearbyClubs(Double lat, Double lng, Double radius) {
        log.info("获取附近俱乐部，坐标：{},{}，半径：{}km", lat, lng, radius);
        
        if (lat == null || lng == null) {
            throw new IllegalArgumentException("坐标不能为空");
        }
        
        if (radius == null || radius <= 0) {
            radius = 10.0; // 默认半径10km
        }
        
        List<Club> clubs = clubMapper.selectNearbyClubs(lat, lng, radius);
        
        log.info("查询到{}个附近俱乐部", clubs.size());
        return clubs.stream()
                .map(clubConverter::toDTO)
                .collect(Collectors.toList());
    }
} 