package com.oil.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.entity.Customer;
import com.oil.system.entity.Orders;
import com.oil.system.mapper.CustomerMapper;
import com.oil.system.service.CustomerService;
import com.oil.system.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CustomerServiceImpl extends ServiceImpl<CustomerMapper, Customer> implements CustomerService {

    @Lazy
    @Autowired
    private OrderService orderService;

    @Override
    @Transactional
    public void deleteById(Long id, boolean force) {
        if (force) {
            orderService.remove(new LambdaQueryWrapper<Orders>().eq(Orders::getCustomerId, id));
        }
        removeById(id);
    }
}
