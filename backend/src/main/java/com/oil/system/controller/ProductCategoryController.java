package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.oil.system.dto.Result;
import com.oil.system.entity.ProductCategory;
import com.oil.system.service.ProductCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/category")
@RequiredArgsConstructor
@CrossOrigin
public class ProductCategoryController {

    private final ProductCategoryService categoryService;

    /**
     * 获取所有分类列表
     */
    @GetMapping("/list")
    public Result<List<ProductCategory>> list() {
        LambdaQueryWrapper<ProductCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(ProductCategory::getSort);
        List<ProductCategory> list = categoryService.list(wrapper);
        return Result.success(list);
    }

    /**
     * 新增分类
     */
    @PostMapping
    public Result<Void> save(@RequestBody ProductCategory category) {
        categoryService.save(category);
        return Result.success();
    }

    /**
     * 更新分类
     */
    @PutMapping
    public Result<Void> update(@RequestBody ProductCategory category) {
        categoryService.updateById(category);
        return Result.success();
    }

    /**
     * 删除分类
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        categoryService.removeById(id);
        return Result.success();
    }
}
