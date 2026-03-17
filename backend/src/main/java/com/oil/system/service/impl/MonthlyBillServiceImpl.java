package com.oil.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.entity.*;
import com.oil.system.mapper.MonthlyBillMapper;
import com.oil.system.service.*;
import com.oil.system.util.ExcelUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MonthlyBillServiceImpl extends ServiceImpl<MonthlyBillMapper, MonthlyBill> implements MonthlyBillService {

    private final OrderService orderService;
    private final OrderItemService orderItemService;
    private final CustomerService customerService;
    private final ProductService productService;

    @Override
    @Transactional
    public MonthlyBill generateMonthlyBill(Long customerId, String billMonth, String startDate, String endDate, List<Long> categoryIds) {
        System.out.println("===== 生成月结账单 =====");
        System.out.println("客户ID: " + customerId);
        System.out.println("账单月份: " + billMonth);
        System.out.println("开始日期: " + startDate);
        System.out.println("结束日期: " + endDate);
        System.out.println("类别IDs: " + categoryIds);

        Customer customer = customerService.getById(customerId);
        if (customer == null) {
            throw new RuntimeException("客户不存在");
        }

        // 确定时间范围
        String startTime;
        String endTime;
        String displayPeriod; // 用于显示的账单周期

        if (billMonth != null && !billMonth.isEmpty()) {
            // 按月份模式
            YearMonth yearMonth = YearMonth.parse(billMonth);
            int lastDay = yearMonth.lengthOfMonth();
            startTime = billMonth + "-01 00:00:00";
            endTime = billMonth + "-" + String.format("%02d", lastDay) + " 23:59:59";
            displayPeriod = billMonth;
        } else if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
            // 按日期范围模式
            startTime = startDate + " 00:00:00";
            endTime = endDate + " 23:59:59";
            displayPeriod = startDate + "至" + endDate;
        } else {
            throw new RuntimeException("请指定账单月份或日期范围");
        }

        // 查询该时间范围的所有订单
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Orders::getCustomerId, customerId)
                .ge(Orders::getCreateTime, startTime)
                .le(Orders::getCreateTime, endTime);
        List<Orders> orders = orderService.list(wrapper);
        System.out.println("找到订单数量: " + orders.size());

        // 如果指定了类别，需要筛选订单明细
        BigDecimal totalAmount;
        if (categoryIds != null && !categoryIds.isEmpty()) {
            System.out.println("===== 按类别筛选 =====");
            // 按类别筛选：只统计指定类别的商品金额
            totalAmount = BigDecimal.ZERO;
            for (Orders order : orders) {
                // 查询该订单的所有明细
                LambdaQueryWrapper<OrderItem> itemWrapper = new LambdaQueryWrapper<>();
                itemWrapper.eq(OrderItem::getOrderId, order.getId());
                List<OrderItem> items = orderItemService.list(itemWrapper);
                System.out.println("订单 " + order.getId() + " 明细数: " + items.size());

                // 筛选指定类别的商品
                for (OrderItem item : items) {
                    Product product = productService.getById(item.getProductId());
                    System.out.println("  商品 " + item.getProductId() + " (" + (product != null ? product.getName() : "null") + ") 类别: " + (product != null ? product.getCategoryId() : "null"));
                    if (product != null && categoryIds.contains(product.getCategoryId())) {
                        System.out.println("    ✓ 匹配类别，金额: " + item.getSubtotal());
                        totalAmount = totalAmount.add(item.getSubtotal());
                    } else {
                        System.out.println("    ✗ 不匹配类别");
                    }
                }
            }
            System.out.println("筛选后总金额: " + totalAmount);
        } else {
            // 不限制类别：统计所有订单金额
            totalAmount = orders.stream()
                    .map(Orders::getTotalAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
        }

        // 记录关联的订单ID列表（JSON格式），防止后续订单变动导致账单数据不一致
        String orderIds = "[" + orders.stream()
                .map(o -> String.valueOf(o.getId()))
                .collect(Collectors.joining(",")) + "]";

        // 记录类别ID列表
        String categoryIdsStr = categoryIds != null && !categoryIds.isEmpty()
                ? "[" + categoryIds.stream().map(String::valueOf).collect(Collectors.joining(",")) + "]"
                : null;

        // 创建账单
        MonthlyBill bill = new MonthlyBill();
        bill.setBillNo(generateBillNo());
        bill.setCustomerId(customerId);
        bill.setCustomerName(customer.getName());
        bill.setBillMonth(displayPeriod); // 存储显示用的周期字符串
        bill.setTotalAmount(totalAmount);
        bill.setPaidAmount(BigDecimal.ZERO);
        bill.setOrderIds(orderIds);
        bill.setCategoryIds(categoryIdsStr);
        // 根据客户类型设置状态：月结客户为"未结算"，其他客户为"已结算"
        bill.setStatus(customer.getIsMonthly() == 1 ? "未结清" : "已结清");
        save(bill);

        return bill;
    }

    @Override
    @Transactional
    public void settle(Long billId) {
        MonthlyBill bill = getById(billId);
        if (bill == null) {
            throw new RuntimeException("账单不存在");
        }

        // 切换结算状态
        if ("已结清".equals(bill.getStatus())) {
            // 已结清 -> 未结清
            bill.setStatus("未结清");
            bill.setPaidAmount(BigDecimal.ZERO);
            bill.setSettlementDate(null);
        } else {
            // 未结清 -> 已结清
            bill.setStatus("已结清");
            bill.setPaidAmount(bill.getTotalAmount());
            bill.setSettlementDate(LocalDate.now());
        }
        updateById(bill);
    }

    @Override
    public void exportToExcel(Long billId, HttpServletResponse response) {
        MonthlyBill bill = getById(billId);
        if (bill == null) {
            throw new RuntimeException("账单不存在");
        }

        // 查询账单对应的订单：优先按保存的orderIds查，兼容旧账单（无orderIds时按日期范围查）
        List<Orders> orders;
        if (bill.getOrderIds() != null && !bill.getOrderIds().equals("[]") && !bill.getOrderIds().isEmpty()) {
            // 新逻辑：按生成账单时记录的订单ID精确查询，不受后续订单增删影响
            String ids = bill.getOrderIds().replaceAll("[\\[\\]\\s]", "");
            List<Long> idList = java.util.Arrays.stream(ids.split(","))
                    .map(Long::parseLong)
                    .collect(Collectors.toList());
            LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
            wrapper.in(Orders::getId, idList);
            orders = orderService.list(wrapper);
        } else {
            // 兼容旧账单：按日期范围查询
            String billMonth = bill.getBillMonth();
            String startTime;
            String endTime;

            // 判断是月份格式还是日期范围格式
            if (billMonth.contains("至")) {
                // 日期范围格式：2026-03-15至2026-03-17
                String[] dates = billMonth.split("至");
                startTime = dates[0] + " 00:00:00";
                endTime = dates[1] + " 23:59:59";
            } else {
                // 月份格式：2026-03
                YearMonth yearMonth = YearMonth.parse(billMonth);
                int lastDay = yearMonth.lengthOfMonth();
                startTime = billMonth + "-01 00:00:00";
                endTime = billMonth + "-" + String.format("%02d", lastDay) + " 23:59:59";
            }

            LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Orders::getCustomerId, bill.getCustomerId())
                    .ge(Orders::getCreateTime, startTime)
                    .le(Orders::getCreateTime, endTime);
            orders = orderService.list(wrapper);
        }

        // 解析类别ID列表
        List<Long> categoryIds = null;
        if (bill.getCategoryIds() != null && !bill.getCategoryIds().equals("[]") && !bill.getCategoryIds().isEmpty()) {
            String ids = bill.getCategoryIds().replaceAll("[\\[\\]\\s]", "");
            categoryIds = java.util.Arrays.stream(ids.split(","))
                    .map(Long::parseLong)
                    .collect(Collectors.toList());
        }

        // 导出Excel（传入类别ID列表用于筛选）
        ExcelUtil.exportMonthlyBill(bill, orders, orderItemService, productService, categoryIds, response);
    }

    @Override
    public Map<String, Object> getBillDetail(Long billId) {
        MonthlyBill bill = getById(billId);
        if (bill == null) {
            throw new RuntimeException("账单不存在");
        }

        // 查询账单对应的订单
        List<Orders> orders;
        if (bill.getOrderIds() != null && !bill.getOrderIds().equals("[]") && !bill.getOrderIds().isEmpty()) {
            String ids = bill.getOrderIds().replaceAll("[\\[\\]\\s]", "");
            List<Long> idList = java.util.Arrays.stream(ids.split(","))
                    .map(Long::parseLong)
                    .collect(Collectors.toList());
            LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
            wrapper.in(Orders::getId, idList);
            orders = orderService.list(wrapper);
        } else {
            String billMonth = bill.getBillMonth();
            String startTime;
            String endTime;

            // 判断是月份格式还是日期范围格式
            if (billMonth.contains("至")) {
                // 日期范围格式：2026-03-15至2026-03-17
                String[] dates = billMonth.split("至");
                startTime = dates[0] + " 00:00:00";
                endTime = dates[1] + " 23:59:59";
            } else {
                // 月份格式：2026-03
                YearMonth yearMonth = YearMonth.parse(billMonth);
                int lastDay = yearMonth.lengthOfMonth();
                startTime = billMonth + "-01 00:00:00";
                endTime = billMonth + "-" + String.format("%02d", lastDay) + " 23:59:59";
            }

            LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Orders::getCustomerId, bill.getCustomerId())
                    .ge(Orders::getCreateTime, startTime)
                    .le(Orders::getCreateTime, endTime);
            orders = orderService.list(wrapper);
        }

        // 解析类别ID列表
        List<Long> categoryIds = null;
        if (bill.getCategoryIds() != null && !bill.getCategoryIds().equals("[]") && !bill.getCategoryIds().isEmpty()) {
            String ids = bill.getCategoryIds().replaceAll("[\\[\\]\\s]", "");
            categoryIds = java.util.Arrays.stream(ids.split(","))
                    .map(Long::parseLong)
                    .collect(Collectors.toList());
        }

        // 收集所有订单明细（按类别筛选）
        List<Map<String, Object>> items = new ArrayList<>();
        for (Orders order : orders) {
            LambdaQueryWrapper<OrderItem> itemWrapper = new LambdaQueryWrapper<>();
            itemWrapper.eq(OrderItem::getOrderId, order.getId());
            List<OrderItem> orderItems = orderItemService.list(itemWrapper);

            for (OrderItem item : orderItems) {
                // 检查商品是否存在（过滤已删除的商品）
                Product product = productService.getById(item.getProductId());
                if (product == null) {
                    // 商品已被删除，跳过此明细
                    continue;
                }

                // 如果指定了类别筛选，检查商品是否属于指定类别
                if (categoryIds != null && !categoryIds.isEmpty()) {
                    if (!categoryIds.contains(product.getCategoryId())) {
                        continue;
                    }
                }

                Map<String, Object> itemMap = new HashMap<>();
                itemMap.put("orderNo", order.getOrderNo());
                itemMap.put("orderDate", order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                itemMap.put("productName", item.getProductName());
                itemMap.put("productCode", item.getProductCode());
                itemMap.put("productSpec", item.getProductSpec());
                itemMap.put("unit", item.getUnit());
                itemMap.put("price", item.getPrice());
                itemMap.put("quantity", item.getQuantity());
                itemMap.put("subtotal", item.getSubtotal());
                itemMap.put("remark", order.getRemark());
                items.add(itemMap);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("bill", bill);
        result.put("items", items);
        return result;
    }

    private String generateBillNo() {
        return "BILL" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
    }
}
