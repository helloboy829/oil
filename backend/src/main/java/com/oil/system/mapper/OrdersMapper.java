package com.oil.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oil.system.entity.Orders;
import com.oil.system.vo.StatisticsVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface OrdersMapper extends BaseMapper<Orders> {

    @Select("<script>" +
            "SELECT DATE_FORMAT(o.create_time, #{fmt}) AS date, SUM(o.total_amount) AS amount " +
            "FROM orders o " +
            "WHERE o.deleted = 0 " +
            "<if test='startDate != null'> AND o.create_time &gt;= #{startDate} </if>" +
            "<if test='endDate != null'> AND o.create_time &lt;= #{endDate} </if>" +
            "<if test='customerId != null'> AND o.customer_id = #{customerId} </if>" +
            "<if test='productId != null'> AND EXISTS (" +
                "SELECT 1 FROM order_item oi " +
                "WHERE oi.order_id = o.id AND oi.product_id = #{productId} AND oi.deleted = 0" +
            ") </if>" +
            "GROUP BY DATE_FORMAT(o.create_time, #{fmt}) " +
            "ORDER BY date" +
            "</script>")
    List<StatisticsVO.TrendItem> selectTrend(@Param("fmt") String fmt,
                                              @Param("startDate") String startDate,
                                              @Param("endDate") String endDate,
                                              @Param("customerId") Long customerId,
                                              @Param("productId") Long productId);
}
