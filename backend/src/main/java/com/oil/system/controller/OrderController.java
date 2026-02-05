package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.dto.OrderDTO;
import com.oil.system.dto.Result;
import com.oil.system.entity.Orders;
import com.oil.system.service.OrderService;
import com.oil.system.vo.OrderDetailVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/order")
@RequiredArgsConstructor
@CrossOrigin
public class OrderController {

    private final OrderService orderService;

    /**
     * 分页查询订单
     */
    @GetMapping("/page")
    public Result<Page<Orders>> page(@RequestParam(defaultValue = "1") Integer current,
                                      @RequestParam(defaultValue = "10") Integer size,
                                      @RequestParam(required = false) String orderNo,
                                      @RequestParam(required = false) String customerName) {
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();

        // 订单编号查询：去除首尾空格后进行模糊匹配
        if (orderNo != null && !orderNo.trim().isEmpty()) {
            wrapper.like(Orders::getOrderNo, orderNo.trim());
        }

        // 客户名称查询：去除首尾空格后进行模糊匹配
        if (customerName != null && !customerName.trim().isEmpty()) {
            wrapper.like(Orders::getCustomerName, customerName.trim());
        }

        wrapper.orderByDesc(Orders::getCreateTime);
        Page<Orders> page = orderService.page(new Page<>(current, size), wrapper);
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
