package com.tmcmap.service.impl;

import com.tmcmap.model.dto.NavigationDTO;
import com.tmcmap.service.NavigationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 导航服务实现类
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Slf4j
@Service
public class NavigationServiceImpl implements NavigationService {

    /**
     * 地球半径(千米)
     */
    private static final double EARTH_RADIUS = 6371.0;

    @Override
    public NavigationDTO calculateRoute(Double fromLat, Double fromLng, 
                                       Double toLat, Double toLng, String mode) {
        log.info("计算导航路线，起点：{},{}，终点：{},{}，出行方式：{}", 
                fromLat, fromLng, toLat, toLng, mode);
        
        if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
            throw new IllegalArgumentException("坐标参数不能为空");
        }
        
        // 计算直线距离
        Double distance = calculateDistance(fromLat, fromLng, toLat, toLng);
        
        NavigationDTO navigation = new NavigationDTO();
        navigation.setFromLat(fromLat);
        navigation.setFromLng(fromLng);
        navigation.setToLat(toLat);
        navigation.setToLng(toLng);
        navigation.setMode(mode != null ? mode : "driving");
        navigation.setDistance(distance.intValue());
        
        // 根据出行方式估算时间
        Integer duration = calculateDuration(distance, mode);
        navigation.setDuration(duration);
        
        // 生成路线描述
        String description = generateDescription(distance, duration, mode);
        navigation.setDescription(description);
        
        // 生成推荐路线
        String route = generateRoute(distance, mode);
        navigation.setRoute(route);
        
        log.info("导航计算完成，距离：{}米，时间：{}秒", distance.intValue(), duration);
        return navigation;
    }

    @Override
    public Double calculateDistance(Double fromLat, Double fromLng, 
                                   Double toLat, Double toLng) {
        if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
            throw new IllegalArgumentException("坐标参数不能为空");
        }
        
        // 使用Haversine公式计算球面距离
        double lat1Rad = Math.toRadians(fromLat);
        double lat2Rad = Math.toRadians(toLat);
        double deltaLatRad = Math.toRadians(toLat - fromLat);
        double deltaLngRad = Math.toRadians(toLng - fromLng);
        
        double a = Math.sin(deltaLatRad / 2) * Math.sin(deltaLatRad / 2) +
                   Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                   Math.sin(deltaLngRad / 2) * Math.sin(deltaLngRad / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        // 返回距离(米)
        return EARTH_RADIUS * c * 1000;
    }

    /**
     * 根据距离和出行方式估算时间
     * 
     * @param distance 距离(米)
     * @param mode 出行方式
     * @return 时间(秒)
     */
    private Integer calculateDuration(Double distance, String mode) {
        if (distance == null) {
            return 0;
        }
        
        double hours;
        switch (mode != null ? mode : "driving") {
            case "walking":
                // 步行速度约5km/h
                hours = distance / 1000.0 / 5.0;
                break;
            case "transit":
                // 公交平均速度约20km/h
                hours = distance / 1000.0 / 20.0;
                break;
            case "driving":
            default:
                // 驾车平均速度约40km/h
                hours = distance / 1000.0 / 40.0;
                break;
        }
        
        return (int) (hours * 3600);
    }

    /**
     * 生成路线描述
     * 
     * @param distance 距离(米)
     * @param duration 时间(秒)
     * @param mode 出行方式
     * @return 描述文本
     */
    private String generateDescription(Double distance, Integer duration, String mode) {
        String modeText;
        switch (mode != null ? mode : "driving") {
            case "walking":
                modeText = "步行";
                break;
            case "transit":
                modeText = "公交";
                break;
            case "driving":
            default:
                modeText = "驾车";
                break;
        }
        
        String distanceText;
        if (distance >= 1000) {
            distanceText = String.format("%.1f公里", distance / 1000.0);
        } else {
            distanceText = String.format("%.0f米", distance);
        }
        
        String durationText;
        if (duration >= 3600) {
            int hours = duration / 3600;
            int minutes = (duration % 3600) / 60;
            durationText = String.format("%d小时%d分钟", hours, minutes);
        } else {
            int minutes = duration / 60;
            durationText = String.format("%d分钟", Math.max(1, minutes));
        }
        
        return String.format("%s | %s | %s", modeText, durationText, distanceText);
    }

    /**
     * 生成推荐路线文本
     * 
     * @param distance 距离(米)
     * @param mode 出行方式
     * @return 路线文本
     */
    private String generateRoute(Double distance, String mode) {
        if (distance < 500) {
            return "就近步行即可到达";
        } else if (distance < 2000) {
            return "推荐步行或骑行前往";
        } else if (distance < 10000) {
            return "推荐打车或公交前往";
        } else {
            return "推荐驾车前往，可使用导航软件规划最佳路线";
        }
    }
} 