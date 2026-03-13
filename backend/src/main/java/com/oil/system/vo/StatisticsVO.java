package com.oil.system.vo;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class StatisticsVO {

    /** 销售额趋势 */
    private List<TrendItem> trend;

    /** 商品销量排行 */
    private List<ProductRankItem> productRank;

    /** 客户消费排行 */
    private List<CustomerRankItem> customerRank;

    @Data
    public static class TrendItem {
        private String date;
        private BigDecimal amount;
    }

    @Data
    public static class ProductRankItem {
        private String productName;
        private Integer totalQuantity;
        private BigDecimal totalAmount;
    }

    @Data
    public static class CustomerRankItem {
        private String customerName;
        private BigDecimal totalAmount;
        private Integer orderCount;
    }
}
