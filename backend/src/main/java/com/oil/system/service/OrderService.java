package com.oil.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oil.system.dto.OrderDTO;
import com.oil.system.entity.Orders;

public interface OrderService extends IService<Orders> {
    /**
     * 创建订单
     */
    Orders createOrder(OrderDTO orderDTO);

    /**
     * 根据商品编码扫码添加商品
     */
    void scanProduct(String productCode);
}
