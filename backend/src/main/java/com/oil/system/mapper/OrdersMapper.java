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

    @Select("SELECT DATE_FORMAT(create_time, #{fmt}) AS date, SUM(total_amount) AS amount " +
            "FROM orders WHERE deleted = 0 " +
            "AND create_time >= #{startDate} AND create_time <= #{endDate} " +
            "GROUP BY DATE_FORMAT(create_time, #{fmt}) ORDER BY date")
    List<StatisticsVO.TrendItem> selectTrend(@Param("fmt") String fmt,
                                              @Param("startDate") String startDate,
                                              @Param("endDate") String endDate);
}
