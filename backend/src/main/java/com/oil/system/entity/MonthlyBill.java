package com.oil.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("monthly_bill")
public class MonthlyBill {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String billNo;

    private Long customerId;

    private String customerName;

    private String billMonth;

    private BigDecimal totalAmount;

    private BigDecimal paidAmount;

    private String status;

    private LocalDate settlementDate;

    private String remark;

    @TableLogic
    private Integer deleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
