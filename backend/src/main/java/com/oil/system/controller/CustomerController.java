package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.dto.Result;
import com.oil.system.entity.Customer;
import com.oil.system.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customer")
@RequiredArgsConstructor
@CrossOrigin
public class CustomerController {

    private final CustomerService customerService;

    /**
     * 分页查询客户
     */
    @GetMapping("/page")
    public Result<Page<Customer>> page(@RequestParam(defaultValue = "1") Integer current,
                                        @RequestParam(defaultValue = "10") Integer size,
                                        @RequestParam(required = false) String name,
                                        @RequestParam(required = false) Integer isMonthly) {
        LambdaQueryWrapper<Customer> wrapper = new LambdaQueryWrapper<>();

        // 客户姓名查询
        if (name != null && !name.isEmpty()) {
            wrapper.like(Customer::getName, name);
        }

        // 月结客户查询
        if (isMonthly != null) {
            wrapper.eq(Customer::getIsMonthly, isMonthly);
        }

        // 按创建时间倒序排列，新增的客户显示在最前面
        wrapper.orderByDesc(Customer::getCreateTime);

        Page<Customer> page = customerService.page(new Page<>(current, size), wrapper);
        return Result.success(page);
    }

    /**
     * 查询所有月结客户
     */
    @GetMapping("/monthly")
    public Result<?> getMonthlyCustomers() {
        LambdaQueryWrapper<Customer> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Customer::getIsMonthly, 1);
        return Result.success(customerService.list(wrapper));
    }

    /**
     * 新增客户
     */
    @PostMapping
    public Result<Void> save(@RequestBody Customer customer) {
        customerService.save(customer);
        return Result.success();
    }

    /**
     * 更新客户
     */
    @PutMapping
    public Result<Void> update(@RequestBody Customer customer) {
        customerService.updateById(customer);
        return Result.success();
    }

    /**
     * 删除客户
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        customerService.removeById(id);
        return Result.success();
    }
}
