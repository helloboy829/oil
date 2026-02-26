package com.oil.system.util;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.write.metadata.style.WriteCellStyle;
import com.alibaba.excel.write.metadata.style.WriteFont;
import com.alibaba.excel.write.style.HorizontalCellStyleStrategy;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.oil.system.entity.MonthlyBill;
import com.oil.system.entity.OrderItem;
import com.oil.system.entity.Orders;
import com.oil.system.service.OrderItemService;
import com.oil.system.vo.MonthlyBillExcelVO;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.time.format.DateTimeFormatter;
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
            String fileName = URLEncoder.encode(bill.getCustomerName() + "_" + bill.getBillMonth() + "_月结账单", "UTF-8");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

            // 创建工作簿
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("月结账单");

            // 设置列宽
            sheet.setColumnWidth(0, 3000);  // 序号
            sheet.setColumnWidth(1, 5000);  // 订单日期
            sheet.setColumnWidth(2, 6000);  // 订单编号
            sheet.setColumnWidth(3, 6000);  // 商品名称
            sheet.setColumnWidth(4, 4000);  // 商品编码
            sheet.setColumnWidth(5, 4000);  // 规格型号
            sheet.setColumnWidth(6, 3000);  // 单位
            sheet.setColumnWidth(7, 4000);  // 单价
            sheet.setColumnWidth(8, 3000);  // 数量
            sheet.setColumnWidth(9, 4000);  // 小计

            int rowNum = 0;

            // 创建标题样式
            CellStyle titleStyle = createTitleStyle(workbook);
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle dataStyle = createDataStyle(workbook);
            CellStyle summaryStyle = createSummaryStyle(workbook);

            // 第1行：账单标题
            Row titleRow = sheet.createRow(rowNum++);
            titleRow.setHeight((short) 600);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("月结账单");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 9));

            // 空行
            rowNum++;

            // 账单基本信息
            rowNum = createBillInfo(sheet, workbook, bill, rowNum);

            // 空行
            rowNum++;

            // 表头
            rowNum = createTableHeader(sheet, headerStyle, rowNum);

            // 准备明细数据并计算汇总
            int totalQuantity = 0;
            int orderCount = orders.size();
            BigDecimal actualTotalAmount = BigDecimal.ZERO;

            int serialNo = 1;
            for (Orders order : orders) {
                LambdaQueryWrapper<OrderItem> wrapper = new LambdaQueryWrapper<>();
                wrapper.eq(OrderItem::getOrderId, order.getId());
                List<OrderItem> items = orderItemService.list(wrapper);

                for (OrderItem item : items) {
                    Row dataRow = sheet.createRow(rowNum++);
                    dataRow.setHeight((short) 400);

                    createCell(dataRow, 0, String.valueOf(serialNo++), dataStyle);
                    createCell(dataRow, 1, order.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")), dataStyle);
                    createCell(dataRow, 2, order.getOrderNo(), dataStyle);
                    createCell(dataRow, 3, item.getProductName(), dataStyle);
                    createCell(dataRow, 4, item.getProductCode(), dataStyle);
                    createCell(dataRow, 5, item.getProductSpec(), dataStyle);
                    createCell(dataRow, 6, item.getUnit(), dataStyle);
                    createCell(dataRow, 7, "¥" + item.getPrice().setScale(2, BigDecimal.ROUND_HALF_UP), dataStyle);
                    createCell(dataRow, 8, String.valueOf(item.getQuantity()), dataStyle);
                    createCell(dataRow, 9, "¥" + item.getSubtotal().setScale(2, BigDecimal.ROUND_HALF_UP), dataStyle);

                    totalQuantity += item.getQuantity();
                    actualTotalAmount = actualTotalAmount.add(item.getSubtotal());
                }
            }

            // 空行
            rowNum++;

            // 汇总信息（使用从明细重新计算的实际总金额，确保与明细一致）
            rowNum = createSummary(sheet, summaryStyle, bill, orderCount, totalQuantity, actualTotalAmount, rowNum);

            // 写入响应流
            workbook.write(response.getOutputStream());
            workbook.close();

        } catch (IOException e) {
            throw new RuntimeException("导出Excel失败", e);
        }
    }

    /**
     * 创建标题样式
     */
    private static CellStyle createTitleStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 18);
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    /**
     * 创建表头样式
     */
    private static CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    /**
     * 创建数据样式
     */
    private static CellStyle createDataStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    /**
     * 创建汇总样式
     */
    private static CellStyle createSummaryStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    /**
     * 创建账单基本信息
     */
    private static int createBillInfo(Sheet sheet, Workbook workbook, MonthlyBill bill, int rowNum) {
        CellStyle infoStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setFontHeightInPoints((short) 11);
        infoStyle.setFont(font);
        infoStyle.setAlignment(HorizontalAlignment.LEFT);
        infoStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        // 账单编号
        Row row1 = sheet.createRow(rowNum++);
        row1.setHeight((short) 400);
        Cell cell1 = row1.createCell(0);
        cell1.setCellValue("账单编号：" + bill.getBillNo());
        cell1.setCellStyle(infoStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 4));

        // 客户名称
        Cell cell2 = row1.createCell(5);
        cell2.setCellValue("客户名称：" + bill.getCustomerName());
        cell2.setCellStyle(infoStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 5, 9));

        // 账单月份
        Row row2 = sheet.createRow(rowNum++);
        row2.setHeight((short) 400);
        Cell cell3 = row2.createCell(0);
        cell3.setCellValue("账单月份：" + bill.getBillMonth());
        cell3.setCellStyle(infoStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 4));

        // 账单状态
        Cell cell4 = row2.createCell(5);
        cell4.setCellValue("账单状态：" + bill.getStatus());
        cell4.setCellStyle(infoStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 5, 9));

        return rowNum;
    }

    /**
     * 创建表头
     */
    private static int createTableHeader(Sheet sheet, CellStyle headerStyle, int rowNum) {
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.setHeight((short) 450);

        String[] headers = {"序号", "订单日期", "订单编号", "商品名称", "商品编码", "规格型号", "单位", "单价", "数量", "小计"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        return rowNum;
    }

    /**
     * 创建单元格
     */
    private static void createCell(Row row, int column, String value, CellStyle style) {
        Cell cell = row.createCell(column);
        cell.setCellValue(value);
        cell.setCellStyle(style);
    }

    /**
     * 创建汇总信息
     */
    private static int createSummary(Sheet sheet, CellStyle summaryStyle, MonthlyBill bill,
                                     int orderCount, int totalQuantity, BigDecimal actualTotalAmount, int rowNum) {
        // 订单总数
        Row row1 = sheet.createRow(rowNum++);
        row1.setHeight((short) 400);
        Cell cell1 = row1.createCell(0);
        cell1.setCellValue("订单总数：" + orderCount + " 笔");
        cell1.setCellStyle(summaryStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 4));

        // 商品总数量
        Cell cell2 = row1.createCell(5);
        cell2.setCellValue("商品总数量：" + totalQuantity + " 件");
        cell2.setCellStyle(summaryStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 5, 9));

        // 应付总额（使用从明细重新计算的实际金额）
        Row row2 = sheet.createRow(rowNum++);
        row2.setHeight((short) 400);
        Cell cell3 = row2.createCell(0);
        cell3.setCellValue("应付总额：¥" + actualTotalAmount.setScale(2, BigDecimal.ROUND_HALF_UP));
        cell3.setCellStyle(summaryStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 4));

        // 已付金额
        Cell cell4 = row2.createCell(5);
        cell4.setCellValue("已付金额：¥" + bill.getPaidAmount().setScale(2, BigDecimal.ROUND_HALF_UP));
        cell4.setCellStyle(summaryStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 5, 9));

        // 未付金额
        Row row3 = sheet.createRow(rowNum++);
        row3.setHeight((short) 400);
        BigDecimal unpaidAmount = actualTotalAmount.subtract(bill.getPaidAmount());
        Cell cell5 = row3.createCell(0);
        cell5.setCellValue("未付金额：¥" + unpaidAmount.setScale(2, BigDecimal.ROUND_HALF_UP));
        cell5.setCellStyle(summaryStyle);
        sheet.addMergedRegion(new CellRangeAddress(rowNum - 1, rowNum - 1, 0, 4));

        return rowNum;
    }
}
