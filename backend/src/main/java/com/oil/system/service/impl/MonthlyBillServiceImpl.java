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
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MonthlyBillServiceImpl extends ServiceImpl<MonthlyBillMapper, MonthlyBill> implements MonthlyBillService {

    private final OrderService orderService;
    private final OrderItemService orderItemService;
    private final CustomerService customerService;

    @Override
    @Transactional
    public MonthlyBill generateMonthlyBill(Long customerId, String billMonth) {
        Customer customer = customerService.getById(customerId);
        if (customer == null) {
            throw new RuntimeException("客户不存在");
        }

        // 查询该月的所有订单（不限制支付方式，支持所有客户）
        // 解析账单月份，例如 "2026-02" -> 2026年2月1日 00:00:00 到 2026年2月28日 23:59:59
        YearMonth yearMonth = YearMonth.parse(billMonth);
        int lastDay = yearMonth.lengthOfMonth(); // 获取该月的实际天数
        String startTime = billMonth + "-01 00:00:00";
        String endTime = billMonth + "-" + String.format("%02d", lastDay) + " 23:59:59";

        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Orders::getCustomerId, customerId)
                .ge(Orders::getCreateTime, startTime)
                .le(Orders::getCreateTime, endTime);
        List<Orders> orders = orderService.list(wrapper);

        // 计算总金额
        BigDecimal totalAmount = orders.stream()
                .map(Orders::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 记录关联的订单ID列表（JSON格式），防止后续订单变动导致账单数据不一致
        String orderIds = "[" + orders.stream()
                .map(o -> String.valueOf(o.getId()))
                .collect(Collectors.joining(",")) + "]";

        // 创建账单
        MonthlyBill bill = new MonthlyBill();
        bill.setBillNo(generateBillNo());
        bill.setCustomerId(customerId);
        bill.setCustomerName(customer.getName());
        bill.setBillMonth(billMonth);
        bill.setTotalAmount(totalAmount);
        bill.setPaidAmount(BigDecimal.ZERO);
        bill.setOrderIds(orderIds);
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
            YearMonth yearMonth = YearMonth.parse(billMonth);
            int lastDay = yearMonth.lengthOfMonth();
            String startTime = billMonth + "-01 00:00:00";
            String endTime = billMonth + "-" + String.format("%02d", lastDay) + " 23:59:59";
            LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Orders::getCustomerId, bill.getCustomerId())
                    .ge(Orders::getCreateTime, startTime)
                    .le(Orders::getCreateTime, endTime);
            orders = orderService.list(wrapper);
        }

        // 导出Excel
        ExcelUtil.exportMonthlyBill(bill, orders, orderItemService, response);
    }

    private String generateBillNo() {
        return "BILL" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
    }
}
