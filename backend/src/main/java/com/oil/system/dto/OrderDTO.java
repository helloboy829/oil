package com.oil.system.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class OrderDTO {
    private Long customerId;
    private String customerName;
    private String paymentType;
    private String remark;
    private List<OrderItemDTO> items;
    private LocalDateTime createTime;  // 创建时间（可选，仅管理员可设置）
}
