package com.oil.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.entity.Customer;
import com.oil.system.entity.Orders;
import com.oil.system.mapper.CustomerMapper;
import com.oil.system.service.CustomerService;
import com.oil.system.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl extends ServiceImpl<CustomerMapper, Customer> implements CustomerService {

    @Lazy
    private final OrderService orderService;

    @Override
    @Transactional
    public void deleteById(Long id, boolean force) {
        if (force) {
            // 强制删除：同时软删除该客户下的所有订单
            orderService.remove(new LambdaQueryWrapper<Orders>().eq(Orders::getCustomerId, id));
        }
        removeById(id);
    }
}
