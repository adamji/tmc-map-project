package com.tmcmap.util;

import com.tmcmap.model.dto.ClubDTO;
import com.tmcmap.model.entity.Club;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.springframework.stereotype.Component;

/**
 * 俱乐部实体与DTO转换器
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Mapper(componentModel = "spring")
@Component
public interface ClubConverter {

    /**
     * 实体转DTO
     * 
     * @param club 俱乐部实体
     * @return 俱乐部DTO
     */
    @Mapping(source = "latitude", target = "lat")
    @Mapping(source = "longitude", target = "lng")
    ClubDTO toDTO(Club club);

    /**
     * DTO转实体
     * 
     * @param clubDTO 俱乐部DTO
     * @return 俱乐部实体
     */
    @Mapping(source = "lat", target = "latitude")
    @Mapping(source = "lng", target = "longitude")
    Club toEntity(ClubDTO clubDTO);
} 