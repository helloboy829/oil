package com.oil.system.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProfitStatisticsVO {
    /**
     * 总利润
     */
    private BigDecimal totalProfit;

    /**
     * 平均利润率（%）
     */
    private BigDecimal avgProfitRate;

    /**
     * 有成本数据的商品数量
     */
    private Integer profitableProductCount;

    /**
     * 总商品数量
     */
    private Integer totalProductCount;

    /**
     * 无成本数据的商品数量
     */
    private Integer noCostProductCount;

    /**
     * 最高利润商品名称
     */
    private String topProfitProduct;

    /**
     * 利润趋势数据
     */
    private List<TrendData> profitTrend;

    /**
     * 商品利润排行
     */
    private List<ProductProfitRank> productRank;

    /**
     * 客户利润贡献排行
     */
    private List<CustomerProfitRank> customerRank;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TrendData {
        private String date;
        private BigDecimal profit;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProductProfitRank {
        private String productName;
        private Integer quantity;
        private BigDecimal totalProfit;
        private BigDecimal avgProfitRate;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CustomerProfitRank {
        private String customerName;
        private Integer orderCount;
        private BigDecimal totalProfit;
    }
}
