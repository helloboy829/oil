package com.oil.system.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 类别及商品数量DTO（支持树形结构）
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
     * 父分类ID
     */
    private Long parentId;

    /**
     * 该类别下的商品数量（库存总量）
     */
    private Long productCount;

    /**
     * 子分类列表
     */
    private List<CategoryWithCountDTO> children;

    // 便捷构造方法（不含children）
    public CategoryWithCountDTO(Long id, String name, Integer sort, Long parentId, Long productCount) {
        this.id = id;
        this.name = name;
        this.sort = sort;
        this.parentId = parentId;
        this.productCount = productCount;
    }
}
