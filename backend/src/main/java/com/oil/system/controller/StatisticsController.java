package com.oil.system.controller;

import com.oil.system.dto.Result;
import com.oil.system.mapper.OrderItemMapper;
import com.oil.system.mapper.OrdersMapper;
import com.oil.system.vo.StatisticsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
@CrossOrigin
public class StatisticsController {

    private final OrdersMapper ordersMapper;
    private final OrderItemMapper orderItemMapper;

    /**
     * 获取统计数据
     * @param type  趋势粒度：day / week / month
     * @param start 开始日期，如 2026-01-01
     * @param end   结束日期，如 2026-03-13
     */
    @GetMapping
    public Result<StatisticsVO> getStatistics(
            @RequestParam(defaultValue = "day") String type,
            @RequestParam(required = false) String start,
            @RequestParam(required = false) String end) {

        // 默认最近 30 天
        DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        if (end == null || end.isEmpty()) {
            end = LocalDate.now().format(dayFmt);
        }
        if (start == null || start.isEmpty()) {
            start = LocalDate.now().minusDays(29).format(dayFmt);
        }

        String startDateTime = start + " 00:00:00";
        String endDateTime = end + " 23:59:59";

        // 趋势格式
        String fmt = switch (type) {
            case "month" -> "%Y-%m";
            case "week"  -> "%x-%v";  // ISO year-week
            default      -> "%Y-%m-%d";
        };

        List<StatisticsVO.TrendItem> trend =
                ordersMapper.selectTrend(fmt, startDateTime, endDateTime);

        List<StatisticsVO.ProductRankItem> productRank =
                orderItemMapper.selectProductRank(startDateTime, endDateTime, 10);

        List<StatisticsVO.CustomerRankItem> customerRank =
                orderItemMapper.selectCustomerRank(startDateTime, endDateTime, 10);

        StatisticsVO vo = new StatisticsVO();
        vo.setTrend(trend);
        vo.setProductRank(productRank);
        vo.setCustomerRank(customerRank);

        return Result.success(vo);
    }
}
