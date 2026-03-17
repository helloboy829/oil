package com.oil.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oil.system.entity.MonthlyBill;

import javax.servlet.http.HttpServletResponse;
import java.util.Map;

public interface MonthlyBillService extends IService<MonthlyBill> {
    /**
     * 生成月结账单
     * @param billMonth 账单月份（如 2026-03），与 startDate/endDate 二选一
     * @param startDate 开始日期（如 2026-03-01），与 billMonth 二选一
     * @param endDate 结束日期（如 2026-03-15），与 billMonth 二选一
     * @param categoryIds 商品类别ID列表，为空或null表示不限制类别
     */
    MonthlyBill generateMonthlyBill(Long customerId, String billMonth, String startDate, String endDate, java.util.List<Long> categoryIds);

    /**
     * 结算月结账单
     */
    void settle(Long billId);

    /**
     * 导出月结账单为Excel
     */
    void exportToExcel(Long billId, HttpServletResponse response);

    /**
     * 获取账单详情（包含订单明细）
     */
    Map<String, Object> getBillDetail(Long billId);
}
