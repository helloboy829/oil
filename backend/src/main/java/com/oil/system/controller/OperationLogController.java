package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.dto.Result;
import com.oil.system.entity.OperationLog;
import com.oil.system.mapper.OperationLogMapper;
import com.oil.system.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/operation-log")
@RequiredArgsConstructor
@CrossOrigin
public class OperationLogController {

    private final OperationLogMapper operationLogMapper;

    @Value("${jwt.secret:oil-system-secret-key-must-be-at-least-32-characters-long}")
    private String jwtSecret;

    /**
     * 分页查询操作日志（仅管理员）
     */
    @GetMapping("/page")
    public Result<Page<OperationLog>> page(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String action,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String operatorName,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        // 管理员权限校验
        if (!JwtUtil.isAdmin(authHeader, jwtSecret)) {
            return Result.error("无权限访问");
        }

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
