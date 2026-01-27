package com.oil.system.vo;

import com.oil.system.entity.OrderItem;
import com.oil.system.entity.Orders;
import lombok.Data;

import java.util.List;

/**
 * 订单详情VO
 * 包含订单基本信息和订单明细
 */
@Data
public class OrderDetailVO {
    /**
     * 订单基本信息
     */
    private Orders order;

    /**
     * 订单明细列表
     */
    private List<OrderItem> items;
}
