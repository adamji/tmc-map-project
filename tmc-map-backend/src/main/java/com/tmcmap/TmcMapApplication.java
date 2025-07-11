package com.tmcmap;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 头马俱乐部地图应用启动类
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@SpringBootApplication
@MapperScan("com.tmcmap.repository.mapper")
public class TmcMapApplication {

    public static void main(String[] args) {
        SpringApplication.run(TmcMapApplication.class, args);
    }
} 