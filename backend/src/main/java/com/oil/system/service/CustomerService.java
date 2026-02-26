package com.oil.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oil.system.entity.Customer;

public interface CustomerService extends IService<Customer> {
    void deleteById(Long id, boolean force);
}
