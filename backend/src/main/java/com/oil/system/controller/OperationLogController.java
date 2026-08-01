package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.dto.Result;
import com.oil.system.entity.OperationLog;
import com.oil.system.mapper.OperationLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/operation-log")
@RequiredArgsConstructor
@CrossOrigin
public class OperationLogController {

    private final OperationLogMapper operationLogMapper;

    /**
     * 分页查询操作日志（所有用户均可查看）
     */
    @GetMapping("/page")
    public Result<Page<OperationLog>> page(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String action,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String operatorName) {

        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();

        if (module != null && !module.isEmpty()) {
            wrapper.eq(OperationLog::getModule, module);
        }
        if (action != null && !action.isEmpty()) {
            wrapper.eq(OperationLog::getAction, action);
        }
        if (operatorName != null && !operatorName.isEmpty()) {
            wrapper.like(OperationLog::getOperatorName, operatorName);
        }
        if (startDate != null && !startDate.isEmpty()) {
            wrapper.ge(OperationLog::getCreateTime, startDate + " 00:00:00");
        }
        if (endDate != null && !endDate.isEmpty()) {
            wrapper.le(OperationLog::getCreateTime, endDate + " 23:59:59");
        }

        wrapper.orderByDesc(OperationLog::getCreateTime);

        Page<OperationLog> page = operationLogMapper.selectPage(new Page<>(current, size), wrapper);
        return Result.success(page);
    }
}
