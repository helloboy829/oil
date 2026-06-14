package com.oil.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oil.system.entity.OrderItem;
import com.oil.system.vo.StatisticsVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface OrderItemMapper extends BaseMapper<OrderItem> {

    @Select("<script>" +
            "SELECT oi.product_name AS productName, " +
            "SUM(oi.quantity) AS totalQuantity, SUM(oi.subtotal) AS totalAmount " +
            "FROM order_item oi " +
            "JOIN orders o ON oi.order_id = o.id " +
            "WHERE oi.deleted = 0 AND o.deleted = 0 " +
            "<if test='startDate != null'> AND o.create_time &gt;= #{startDate} </if>" +
            "<if test='endDate != null'> AND o.create_time &lt;= #{endDate} </if>" +
            "<if test='customerId != null'> AND o.customer_id = #{customerId} </if>" +
            "<if test='productId != null'> AND oi.product_id = #{productId} </if>" +
            "GROUP BY oi.product_name ORDER BY totalAmount DESC LIMIT #{limit}" +
            "</script>")
    List<StatisticsVO.ProductRankItem> selectProductRank(@Param("startDate") String startDate,
                                                          @Param("endDate") String endDate,
                                                          @Param("customerId") Long customerId,
                                                          @Param("productId") Long productId,
                                                          @Param("limit") int limit);

    @Select("<script>" +
            "SELECT o.customer_name AS customerName, " +
            "SUM(o.total_amount) AS totalAmount, COUNT(o.id) AS orderCount " +
            "FROM orders o " +
            "WHERE o.deleted = 0 " +
            "AND o.customer_name IS NOT NULL AND o.customer_name != '' " +
            "<if test='startDate != null'> AND o.create_time &gt;= #{startDate} </if>" +
            "<if test='endDate != null'> AND o.create_time &lt;= #{endDate} </if>" +
            "<if test='customerId != null'> AND o.customer_id = #{customerId} </if>" +
            "<if test='productId != null'> AND EXISTS (" +
                "SELECT 1 FROM order_item oi " +
                "WHERE oi.order_id = o.id AND oi.product_id = #{productId} AND oi.deleted = 0" +
            ") </if>" +
            "GROUP BY o.customer_name ORDER BY totalAmount DESC LIMIT #{limit}" +
            "</script>")
    List<StatisticsVO.CustomerRankItem> selectCustomerRank(@Param("startDate") String startDate,
                                                            @Param("endDate") String endDate,
                                                            @Param("customerId") Long customerId,
                                                            @Param("productId") Long productId,
                                                            @Param("limit") int limit);

    // 利润统计相关查询
    List<Map<String, Object>> selectProfitTrend(@Param("fmt") String fmt,
                                                 @Param("startDate") String startDate,
                                                 @Param("endDate") String endDate,
                                                 @Param("customerId") Long customerId,
                                                 @Param("productId") Long productId);

    List<Map<String, Object>> selectProductProfitRank(@Param("startDate") String startDate,
                                                       @Param("endDate") String endDate,
                                                       @Param("customerId") Long customerId,
                                                       @Param("productId") Long productId);

    List<Map<String, Object>> selectCustomerProfitRank(@Param("startDate") String startDate,
                                                        @Param("endDate") String endDate,
                                                        @Param("customerId") Long customerId,
                                                        @Param("productId") Long productId);

    Map<String, Object> selectProfitSummary(@Param("startDate") String startDate,
                                             @Param("endDate") String endDate,
                                             @Param("customerId") Long customerId,
                                             @Param("productId") Long productId);
}
