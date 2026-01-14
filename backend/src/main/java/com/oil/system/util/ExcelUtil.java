package com.oil.system.util;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.write.style.column.LongestMatchColumnWidthStyleStrategy;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.oil.system.entity.MonthlyBill;
import com.oil.system.entity.OrderItem;
import com.oil.system.entity.Orders;
import com.oil.system.service.OrderItemService;
import com.oil.system.vo.MonthlyBillExcelVO;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

public class ExcelUtil {

    /**
     * 导出月结账单
     */
    public static void exportMonthlyBill(MonthlyBill bill, List<Orders> orders,
                                         OrderItemService orderItemService,
                                         HttpServletResponse response) {
        try {
            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            String fileName = URLEncoder.encode("月结账单_" + bill.getBillNo(), "UTF-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

            // 准备数据
            List<MonthlyBillExcelVO> data = new ArrayList<>();
            for (Orders order : orders) {
                LambdaQueryWrapper<OrderItem> wrapper = new LambdaQueryWrapper<>();
                wrapper.eq(OrderItem::getOrderId, order.getId());
                List<OrderItem> items = orderItemService.list(wrapper);

                for (OrderItem item : items) {
                    MonthlyBillExcelVO vo = new MonthlyBillExcelVO();
                    vo.setOrderNo(order.getOrderNo());
                    vo.setOrderDate(order.getCreateTime().toLocalDate().toString());
                    vo.setProductName(item.getProductName());
                    vo.setProductCode(item.getProductCode());
                    vo.setProductSpec(item.getProductSpec());
                    vo.setUnit(item.getUnit());
                    vo.setPrice(item.getPrice());
                    vo.setQuantity(item.getQuantity());
                    vo.setSubtotal(item.getSubtotal());
                    data.add(vo);
                }
            }

            // 导出Excel
            EasyExcel.write(response.getOutputStream(), MonthlyBillExcelVO.class)
                    .registerWriteHandler(new LongestMatchColumnWidthStyleStrategy())
                    .sheet("月结账单")
                    .doWrite(data);

        } catch (IOException e) {
            throw new RuntimeException("导出Excel失败", e);
        }
    }
}
