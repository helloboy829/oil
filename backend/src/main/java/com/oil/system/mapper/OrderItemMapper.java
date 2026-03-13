package com.oil.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oil.system.entity.OrderItem;
import com.oil.system.vo.StatisticsVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface OrderItemMapper extends BaseMapper<OrderItem> {

    @Select("SELECT oi.product_name AS productName, " +
            "SUM(oi.quantity) AS totalQuantity, SUM(oi.subtotal) AS totalAmount " +
            "FROM order_item oi " +
            "JOIN orders o ON oi.order_id = o.id " +
            "WHERE oi.deleted = 0 AND o.deleted = 0 " +
            "AND o.create_time >= #{startDate} AND o.create_time <= #{endDate} " +
            "GROUP BY oi.product_name ORDER BY totalAmount DESC LIMIT #{limit}")
    List<StatisticsVO.ProductRankItem> selectProductRank(@Param("startDate") String startDate,
                                                          @Param("endDate") String endDate,
                                                          @Param("limit") int limit);

    @Select("SELECT o.customer_name AS customerName, " +
            "SUM(o.total_amount) AS totalAmount, COUNT(o.id) AS orderCount " +
            "FROM orders o " +
            "WHERE o.deleted = 0 " +
            "AND o.create_time >= #{startDate} AND o.create_time <= #{endDate} " +
            "AND o.customer_name IS NOT NULL AND o.customer_name != '' " +
            "GROUP BY o.customer_name ORDER BY totalAmount DESC LIMIT #{limit}")
    List<StatisticsVO.CustomerRankItem> selectCustomerRank(@Param("startDate") String startDate,
                                                            @Param("endDate") String endDate,
                                                            @Param("limit") int limit);
}
