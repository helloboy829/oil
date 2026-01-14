package com.oil.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.dto.OrderDTO;
import com.oil.system.dto.OrderItemDTO;
import com.oil.system.entity.*;
import com.oil.system.mapper.OrdersMapper;
import com.oil.system.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl extends ServiceImpl<OrdersMapper, Orders> implements OrderService {

    private final ProductService productService;
    private final OrderItemService orderItemService;
    private final CustomerService customerService;

    @Override
    @Transactional
    public Orders createOrder(OrderDTO orderDTO) {
        // 计算订单总金额
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (OrderItemDTO itemDTO : orderDTO.getItems()) {
            Product product = productService.getById(itemDTO.getProductId());
            if (product == null) {
                throw new RuntimeException("商品不存在: " + itemDTO.getProductId());
            }
            // 检查库存
            if (product.getStock() < itemDTO.getQuantity()) {
                throw new RuntimeException("商品库存不足: " + product.getName() + " (库存: " + product.getStock() + ")");
            }
            BigDecimal subtotal = product.getPrice().multiply(new BigDecimal(itemDTO.getQuantity()));
            totalAmount = totalAmount.add(subtotal);
        }

        // 创建订单
        Orders order = new Orders();
        order.setOrderNo(generateOrderNo());
        order.setCustomerId(orderDTO.getCustomerId());
        order.setCustomerName(orderDTO.getCustomerName());
        order.setPaymentType(orderDTO.getPaymentType());
        // 月结订单标记为未结算,其他标记为已结算
        order.setPaymentStatus("月结".equals(orderDTO.getPaymentType()) ? "未结算" : "已结算");
        order.setRemark(orderDTO.getRemark());
        order.setOrderStatus("已完成");
        order.setTotalAmount(totalAmount);

        // 保存订单
        save(order);

        // 保存订单明细并扣减库存
        for (OrderItemDTO itemDTO : orderDTO.getItems()) {
            Product product = productService.getById(itemDTO.getProductId());
            if (product != null) {
                OrderItem item = new OrderItem();
                item.setOrderId(order.getId());
                item.setProductId(product.getId());
                item.setProductName(product.getName());
                item.setProductCode(product.getCode());
                item.setProductSpec(product.getSpec());
                item.setUnit(product.getUnit());
                item.setPrice(product.getPrice());
                item.setQuantity(itemDTO.getQuantity());
                item.setSubtotal(product.getPrice().multiply(new BigDecimal(itemDTO.getQuantity())));
                orderItemService.save(item);

                // 扣减库存
                product.setStock(product.getStock() - itemDTO.getQuantity());
                productService.updateById(product);
            }
        }

        return order;
    }

    @Override
    public void scanProduct(String productCode) {
        // 扫码逻辑，可以在前端实现
    }

    private String generateOrderNo() {
        return "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
    }
}
