package com.oil.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.dto.OrderDTO;
import com.oil.system.dto.OrderItemDTO;
import com.oil.system.entity.*;
import com.oil.system.mapper.OrdersMapper;
import com.oil.system.service.*;
import com.oil.system.vo.OrderDetailVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

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
            // 优先使用商品编码查询，如果没有编码则使用ID查询
            Product product = null;
            if (itemDTO.getProductCode() != null && !itemDTO.getProductCode().isEmpty()) {
                // 通过商品编码查询
                product = productService.lambdaQuery()
                        .eq(Product::getCode, itemDTO.getProductCode())
                        .one();
            } else if (itemDTO.getProductId() != null) {
                // 通过商品ID查询
                product = productService.getById(itemDTO.getProductId());
            }

            if (product == null) {
                String identifier = itemDTO.getProductCode() != null ? itemDTO.getProductCode() : String.valueOf(itemDTO.getProductId());
                throw new RuntimeException("商品不存在: " + identifier);
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
        order.setRemark(orderDTO.getRemark());
        order.setTotalAmount(totalAmount);

        // 保存订单
        save(order);

        // 保存订单明细并扣减库存
        for (OrderItemDTO itemDTO : orderDTO.getItems()) {
            // 优先使用商品编码查询，如果没有编码则使用ID查询
            Product product = null;
            if (itemDTO.getProductCode() != null && !itemDTO.getProductCode().isEmpty()) {
                product = productService.lambdaQuery()
                        .eq(Product::getCode, itemDTO.getProductCode())
                        .one();
            } else if (itemDTO.getProductId() != null) {
                product = productService.getById(itemDTO.getProductId());
            }

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

    @Override
    public OrderDetailVO getOrderDetail(Long orderId) {
        // 查询订单基本信息
        Orders order = getById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        // 查询订单明细
        List<OrderItem> items = orderItemService.lambdaQuery()
                .eq(OrderItem::getOrderId, orderId)
                .list();

        // 组装返回结果
        OrderDetailVO detailVO = new OrderDetailVO();
        detailVO.setOrder(order);
        detailVO.setItems(items);

        return detailVO;
    }

    private String generateOrderNo() {
        return "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
    }
}
