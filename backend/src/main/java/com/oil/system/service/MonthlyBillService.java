package com.oil.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oil.system.entity.MonthlyBill;

import javax.servlet.http.HttpServletResponse;

public interface MonthlyBillService extends IService<MonthlyBill> {
    /**
     * 生成月结账单
     */
    MonthlyBill generateMonthlyBill(Long customerId, String billMonth);

    /**
     * 导出月结账单为Excel
     */
    void exportToExcel(Long billId, HttpServletResponse response);
}
