package com.oil.system.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class OrderItemDTO {
    private Long productId;
    private String productCode;
    private Integer quantity;
}
