package com.oil.system.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.oil.system.util.LocalDateTimeFlexibleDeserializer;
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

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    @JsonDeserialize(using = LocalDateTimeFlexibleDeserializer.class)
    private LocalDateTime createTime;  // 创建时间（可选，仅管理员可设置）
}
