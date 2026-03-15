package com.oil.system.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 类别及商品数量DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryWithCountDTO {
    /**
     * 类别ID
     */
    private Long id;

    /**
     * 类别名称
     */
    private String name;

    /**
     * 排序
     */
    private Integer sort;

    /**
     * 该类别下的商品数量
     */
    private Long productCount;
}
