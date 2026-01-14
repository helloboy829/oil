package com.oil.system.vo;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class MonthlyBillExcelVO {
    @ExcelProperty("订单编号")
    private String orderNo;

    @ExcelProperty("订单日期")
    private String orderDate;

    @ExcelProperty("商品名称")
    private String productName;

    @ExcelProperty("商品编码")
    private String productCode;

    @ExcelProperty("规格型号")
    private String productSpec;

    @ExcelProperty("单位")
    private String unit;

    @ExcelProperty("单价")
    private BigDecimal price;

    @ExcelProperty("数量")
    private Integer quantity;

    @ExcelProperty("小计")
    private BigDecimal subtotal;
}
