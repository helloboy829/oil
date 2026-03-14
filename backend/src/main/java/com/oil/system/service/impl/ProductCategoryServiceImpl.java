package com.oil.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.entity.ProductCategory;
import com.oil.system.mapper.ProductCategoryMapper;
import com.oil.system.service.ProductCategoryService;
import org.springframework.stereotype.Service;

@Service
public class ProductCategoryServiceImpl extends ServiceImpl<ProductCategoryMapper, ProductCategory> implements ProductCategoryService {
}
