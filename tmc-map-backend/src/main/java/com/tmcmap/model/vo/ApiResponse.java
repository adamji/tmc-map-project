package com.tmcmap.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 统一API响应格式
 * 
 * @author tmcmap
 * @since 2024-01-01
 */
@Data
@Schema(description = "API响应")
public class ApiResponse<T> {

    @Schema(description = "响应码", example = "0")
    private Integer code;

    @Schema(description = "响应消息", example = "success")
    private String msg;

    @Schema(description = "响应数据")
    private T data;

    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(0);
        response.setMsg("success");
        response.setData(data);
        return response;
    }

    public static <T> ApiResponse<T> success() {
        return success(null);
    }

    public static <T> ApiResponse<T> error(String msg) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(-1);
        response.setMsg(msg);
        return response;
    }

    public static <T> ApiResponse<T> error(Integer code, String msg) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setCode(code);
        response.setMsg(msg);
        return response;
    }
} 