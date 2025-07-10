package com.tmcmap.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.ResourceLoader;

/**
 * 资源解析器配置
 * 提供PathMatchingResourcePatternResolver Bean
 */
@Configuration
public class ResourceConfig {

    @Bean
    public PathMatchingResourcePatternResolver pathMatchingResourcePatternResolver(ResourceLoader resourceLoader) {
        return new PathMatchingResourcePatternResolver(resourceLoader);
    }
} 