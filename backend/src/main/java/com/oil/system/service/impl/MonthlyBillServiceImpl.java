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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

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

        // 查询该月的所有订单
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Orders::getCustomerId, customerId)
                .like(Orders::getCreateTime, billMonth)
                .eq(Orders::getPaymentType, "月结");
        List<Orders> orders = orderService.list(wrapper);

        // 计算总金额
        BigDecimal totalAmount = orders.stream()
                .map(Orders::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 创建账单
        MonthlyBill bill = new MonthlyBill();
        bill.setBillNo(generateBillNo());
        bill.setCustomerId(customerId);
        bill.setCustomerName(customer.getName());
        bill.setBillMonth(billMonth);
        bill.setTotalAmount(totalAmount);
        bill.setPaidAmount(BigDecimal.ZERO);
        bill.setStatus("未结算");
        save(bill);

        return bill;
    }

    @Override
    public void exportToExcel(Long billId, HttpServletResponse response) {
        MonthlyBill bill = getById(billId);
        if (bill == null) {
            throw new RuntimeException("账单不存在");
        }

        // 查询账单对应的订单明细
        LambdaQueryWrapper<Orders> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Orders::getCustomerId, bill.getCustomerId())
                .like(Orders::getCreateTime, bill.getBillMonth());
        List<Orders> orders = orderService.list(wrapper);

        // 导出Excel
        ExcelUtil.exportMonthlyBill(bill, orders, orderItemService, response);
    }

    private String generateBillNo() {
        return "BILL" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
    }
}
