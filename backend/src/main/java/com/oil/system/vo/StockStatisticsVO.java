package com.oil.system.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 库存统计数据VO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StockStatisticsVO {
    /**
     * 商品总数
     */
    private Integer totalProductCount;

    /**
     * 库存总量
     */
    private Integer totalStock;

    /**
     * 库存不足商品数（库存 <= 10）
     */
    private Integer lowStockCount;

    /**
     * 零库存商品数
     */
    private Integer zeroStockCount;

    /**
     * 商品类别库存分布
     */
    private List<CategoryStock> categoryStock;

    /**
     * 库存不足商品详情
     */
    private List<LowStockProduct> lowStockProducts;

    /**
     * 库存排行 TOP10
     */
    private List<StockRank> stockRank;

    /**
     * 商品类别库存分布
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CategoryStock {
        private String categoryName;
        private Integer stock;
        private Integer productCount;
    }

    /**
     * 库存不足商品详情
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LowStockProduct {
        private Long id;
        private String name;
        private String categoryName;
        private Integer stock;
        private String unit;
    }

    /**
     * 库存排行
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StockRank {
        private String productName;
        private Integer stock;
        private String categoryName;
    }
}
