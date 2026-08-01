package com.oil.system.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("operation_log")
public class OperationLog {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String module;

    private String action;

    private String description;

    private Long operatorId;

    private String operatorName;

    private String targetId;

    private String targetName;

    private String requestIp;

    private String requestMethod;

    private String requestUrl;

    private String requestParams;

    private String beforeData;

    private String afterData;

    private String status;

    private String errorMsg;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
