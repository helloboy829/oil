package com.oil.system.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderDTO {
    private Long customerId;
    private String customerName;
    private String paymentType;
    private String remark;
    private List<OrderItemDTO> items;
}
