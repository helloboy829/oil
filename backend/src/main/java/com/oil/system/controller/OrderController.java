package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.dto.OrderDTO;
import com.oil.system.dto.Result;
import com.oil.system.entity.Orders;
import com.oil.system.mapper.CustomerMapper;
import com.oil.system.service.OrderService;
import com.oil.system.vo.OrderDetailVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/order")
@RequiredArgsConstructor
@CrossOrigin
public class OrderController {

    private final OrderService orderService;
    private final CustomerMapper customerMapper;

    /**
     * 分页查询订单
     */
    @GetMapping("/page")
    public Result<Page<Orders>> page(@RequestParam(defaultValue = "1") Integer current,
                                      @RequestParam(defaultValue = "10") Integer size,
                                      @RequestParam(required = false) String orderNo,
                                      @RequestParam(required = false) String customerName,
                                      @RequestParam(required = false) String startDate,
                                      @RequestParam(required = false) String endDate) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();

        if (orderNo != null && !orderNo.trim().isEmpty()) {
            wrapper.like(Orders::getOrderNo, orderNo.trim());
        }
        if (customerName != null && !customerName.trim().isEmpty()) {
            wrapper.eq(Orders::getCustomerName, customerName.trim());
        }
        if (startDate != null && !startDate.isEmpty()) {
            wrapper.ge(Orders::getCreateTime, startDate + " 00:00:00");
        }
        if (endDate != null && !endDate.isEmpty()) {
            wrapper.le(Orders::getCreateTime, endDate + " 23:59:59");
        }
        wrapper.orderByDesc(Orders::getCreateTime);

        Page<Orders> page = orderService.page(new Page<>(current, size), wrapper);

        // 批量标记客户是否已被软删除
        List<Orders> records = page.getRecords();
        if (!records.isEmpty()) {
            Set<Long> customerIds = records.stream()
                    .map(Orders::getCustomerId)
                    .filter(id -> id != null)
                    .collect(Collectors.toSet());
            Set<Long> deletedIds = new java.util.HashSet<>(customerMapper.selectDeletedIdsByIds(customerIds));
            records.forEach(o -> o.setCustomerDeleted(deletedIds.contains(o.getCustomerId())));
        }

        return Result.success(page);
    }

    /**
     * 创建订单
     */
    @PostMapping
    public Result<Orders> create(@RequestBody OrderDTO orderDTO) {
        Orders order = orderService.createOrder(orderDTO);
        return Result.success(order);
    }

    /**
     * 查询订单详情（包含订单明细）
     */
    @GetMapping("/{id}")
    public Result<OrderDetailVO> getById(@PathVariable Long id) {
        return Result.success(orderService.getOrderDetail(id));
    }

    /**
     * 删除订单
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        orderService.removeById(id);
        return Result.success();
    }
}
