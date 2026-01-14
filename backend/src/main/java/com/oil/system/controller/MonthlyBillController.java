package com.oil.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.dto.Result;
import com.oil.system.entity.MonthlyBill;
import com.oil.system.service.MonthlyBillService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;

@RestController
@RequestMapping("/api/monthly-bill")
@RequiredArgsConstructor
@CrossOrigin
public class MonthlyBillController {

    private final MonthlyBillService monthlyBillService;

    /**
     * 分页查询月结账单
     */
    @GetMapping("/page")
    public Result<Page<MonthlyBill>> page(@RequestParam(defaultValue = "1") Integer current,
                                           @RequestParam(defaultValue = "10") Integer size) {
        Page<MonthlyBill> page = monthlyBillService.page(new Page<>(current, size));
        return Result.success(page);
    }

    /**
     * 生成月结账单
     */
    @PostMapping("/generate")
    public Result<MonthlyBill> generate(@RequestParam Long customerId,
                                         @RequestParam String billMonth) {
        MonthlyBill bill = monthlyBillService.generateMonthlyBill(customerId, billMonth);
        return Result.success(bill);
    }

    /**
     * 导出月结账单
     */
    @GetMapping("/export/{id}")
    public void export(@PathVariable Long id, HttpServletResponse response) {
        monthlyBillService.exportToExcel(id, response);
    }
}
