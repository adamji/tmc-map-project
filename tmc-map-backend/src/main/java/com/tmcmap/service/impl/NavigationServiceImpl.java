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
     * 地球半径（千米）
     */
    private static final double EARTH_RADIUS = 6371.0;

    @Override
    public NavigationDTO calculateRoute(Double fromLat, Double fromLng,
                                      Double toLat, Double toLng, String mode) {
        log.info("计算导航路线：起点({}, {}), 终点({}, {}), 模式: {}", 
                fromLat, fromLng, toLat, toLng, mode);

        // 计算直线距离
        Double distance = calculateDistance(fromLat, fromLng, toLat, toLng);
        
        // 模拟导航信息（实际项目中应该调用第三方地图API）
        NavigationDTO navigation = new NavigationDTO();
        navigation.setFromLat(fromLat);
        navigation.setFromLng(fromLng);
        navigation.setToLat(toLat);
        navigation.setToLng(toLng);
        navigation.setMode(mode != null ? mode : "driving");
        navigation.setDistance(distance.intValue());
        
        // 根据模式估算时长（简化计算）
        int duration = calculateEstimatedDuration(distance, mode);
        navigation.setDuration(duration);
        
        // 生成描述信息
        String description = generateRouteDescription(distance, duration, mode);
        navigation.setDescription(description);
        
        // 模拟路线信息
        String route = generateRouteInfo(fromLat, fromLng, toLat, toLng);
        navigation.setRoute(route);
        
        log.info("导航路线计算完成：距离{}米，预计用时{}秒", distance, duration);
        return navigation;
    }

    @Override
    public Double calculateDistance(Double fromLat, Double fromLng, 
                                  Double toLat, Double toLng) {
        // 使用 Haversine 公式计算两点间的球面距离
        double lat1Rad = Math.toRadians(fromLat);
        double lon1Rad = Math.toRadians(fromLng);
        double lat2Rad = Math.toRadians(toLat);
        double lon2Rad = Math.toRadians(toLng);

        double deltaLat = lat2Rad - lat1Rad;
        double deltaLon = lon2Rad - lon1Rad;

        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
                   Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                   Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        // 返回米为单位的距离
        return EARTH_RADIUS * c * 1000;
    }

    /**
     * 估算行程时长
     */
    private int calculateEstimatedDuration(Double distance, String mode) {
        double speed; // km/h
        switch (mode != null ? mode.toLowerCase() : "driving") {
            case "walking":
                speed = 5.0; // 步行 5km/h
                break;
            case "transit":
                speed = 25.0; // 公交 25km/h
                break;
            case "driving":
            default:
                speed = 40.0; // 驾车 40km/h
                break;
        }
        return (int) ((distance / 1000) / speed * 3600); // 转换为秒
    }

    /**
     * 生成路线描述
     */
    private String generateRouteDescription(Double distance, int duration, String mode) {
        String modeText = getModeText(mode);
        int minutes = duration / 60;
        double km = distance / 1000.0;
        
        return String.format("%s约%.1f公里，预计用时%d分钟", 
                           modeText, km, minutes);
    }

    /**
     * 获取模式文本
     */
    private String getModeText(String mode) {
        switch (mode != null ? mode.toLowerCase() : "driving") {
            case "walking":
                return "步行";
            case "transit":
                return "公交";
            case "driving":
            default:
                return "驾车";
        }
    }

    /**
     * 生成路线信息
     */
    private String generateRouteInfo(Double fromLat, Double fromLng, 
                                   Double toLat, Double toLng) {
        return String.format("从坐标点(%.4f, %.4f)到坐标点(%.4f, %.4f)的推荐路线", 
                           fromLat, fromLng, toLat, toLng);
    }
} 