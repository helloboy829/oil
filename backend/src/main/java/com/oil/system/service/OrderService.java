package com.oil.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oil.system.dto.OrderDTO;
import com.oil.system.entity.Orders;
import com.oil.system.vo.OrderDetailVO;

public interface OrderService extends IService<Orders> {
    /**
     * 创建订单
     */
    Orders createOrder(OrderDTO orderDTO);

    /**
     * 根据商品编码扫码添加商品
     */
    void scanProduct(String productCode);

    /**
     * 获取订单详情（包含订单明细）
     */
    OrderDetailVO getOrderDetail(Long orderId);
}
