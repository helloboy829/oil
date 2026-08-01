package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.annotation.OperationLog;
import com.oil.system.dto.Result;
import com.oil.system.entity.MonthlyBill;
import com.oil.system.mapper.OperationLogMapper;
import com.oil.system.service.MonthlyBillService;
import com.oil.system.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/monthly-bill")
@RequiredArgsConstructor
@CrossOrigin
public class MonthlyBillController {

    private final MonthlyBillService monthlyBillService;
    private final OperationLogMapper operationLogMapper;

    @Value("${jwt.secret:oil-system-secret-key-must-be-at-least-32-characters-long}")
    private String jwtSecret;

    /**
     * 分页查询月结账单（按生成时间倒序）
     */
    @GetMapping("/page")
    public Result<Page<MonthlyBill>> page(@RequestParam(defaultValue = "1") Integer current,
                                           @RequestParam(defaultValue = "10") Integer size) {
        LambdaQueryWrapper<MonthlyBill> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(MonthlyBill::getCreateTime);
        Page<MonthlyBill> page = monthlyBillService.page(new Page<>(current, size), wrapper);
        return Result.success(page);
    }

    /**
     * 生成月结账单
     */
    @PostMapping("/generate")
    @OperationLog(module = "月结账单", action = "生成账单")
    public Result<MonthlyBill> generate(@RequestParam Long customerId,
                                         @RequestParam(required = false) String billMonth,
                                         @RequestParam(required = false) String startDate,
                                         @RequestParam(required = false) String endDate,
                                         @RequestParam(required = false) java.util.List<Long> categoryIds) {
        MonthlyBill bill = monthlyBillService.generateMonthlyBill(customerId, billMonth, startDate, endDate, categoryIds);
        return Result.success(bill);
    }

    /**
     * 结算月结账单
     */
    @PutMapping("/settle/{id}")
    @OperationLog(module = "月结账单", action = "结算")
    public Result<Void> settle(@PathVariable Long id) {
        monthlyBillService.settle(id);
        return Result.success();
    }

    /**
     * 导出月结账单（手动记录日志，因为直接写 HttpServletResponse）
     */
    @GetMapping("/export/{id}")
    public void export(@PathVariable Long id, HttpServletResponse response,
                       HttpServletRequest request,
                       @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            monthlyBillService.exportToExcel(id, response);
            saveOperationLog("月结账单", "导出", authHeader, request, id.toString(), "成功", null);
        } catch (Exception e) {
            saveOperationLog("月结账单", "导出", authHeader, request, id.toString(), "失败", e.getMessage());
            throw e;
        }
    }

    /**
     * 获取账单详情
     */
    @GetMapping("/{id}")
    public Result<java.util.Map<String, Object>> getDetail(@PathVariable Long id) {
        return Result.success(monthlyBillService.getBillDetail(id));
    }

    /**
     * 删除月结账单
     */
    @DeleteMapping("/{id}")
    @OperationLog(module = "月结账单", action = "删除", targetEntity = MonthlyBill.class)
    public Result<Void> delete(@PathVariable Long id) {
        monthlyBillService.removeById(id);
        return Result.success();
    }

    /**
     * 批量删除月结账单
     */
    @DeleteMapping("/batch")
    @OperationLog(module = "月结账单", action = "批量删除", targetEntity = MonthlyBill.class)
    public Result<Void> deleteBatch(@RequestBody java.util.List<Long> ids) {
        monthlyBillService.removeByIds(ids);
        return Result.success();
    }

    /**
     * 手动记录操作日志（用于 export 等不走 AOP 的特殊场景）
     */
    private void saveOperationLog(String module, String action, String authHeader,
                                  HttpServletRequest request, String targetId,
                                  String status, String errorMsg) {
        try {
            com.oil.system.entity.OperationLog log = new com.oil.system.entity.OperationLog();
            log.setModule(module);
            log.setAction(action);
            log.setDescription(module + "-" + action);
            log.setOperatorName(JwtUtil.getOperatorName(authHeader, jwtSecret));
            log.setOperatorId(JwtUtil.getOperatorId(authHeader, jwtSecret));
            log.setTargetId(targetId);
            log.setRequestIp(getClientIp(request));
            log.setRequestMethod(request.getMethod());
            log.setRequestUrl(request.getRequestURI());
            log.setStatus(status);
            log.setErrorMsg(errorMsg);
            log.setCreateTime(LocalDateTime.now());
            operationLogMapper.insert(log);
        } catch (Exception e) {
            // 日志记录失败不影响业务
        }
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
