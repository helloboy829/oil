package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.oil.system.dto.CategoryWithCountDTO;
import com.oil.system.dto.Result;
import com.oil.system.entity.Product;
import com.oil.system.entity.ProductCategory;
import com.oil.system.service.ProductCategoryService;
import com.oil.system.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/category")
@RequiredArgsConstructor
@CrossOrigin
public class ProductCategoryController {

    private final ProductCategoryService categoryService;
    private final ProductService productService;

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
     * 获取所有分类列表（含商品数量统计）
     */
    @GetMapping("/listWithCount")
    public Result<List<CategoryWithCountDTO>> listWithCount() {
        // 获取所有类别
        LambdaQueryWrapper<ProductCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(ProductCategory::getSort);
        List<ProductCategory> categories = categoryService.list(wrapper);

        // 统计每个类别下的商品数量
        List<CategoryWithCountDTO> result = categories.stream().map(category -> {
            // 查询该类别下的商品数量
            LambdaQueryWrapper<Product> productWrapper = new LambdaQueryWrapper<>();
            productWrapper.eq(Product::getCategoryId, category.getId());
            long count = productService.count(productWrapper);

            // 构建DTO
            return new CategoryWithCountDTO(
                    category.getId(),
                    category.getName(),
                    category.getSort(),
                    count
            );
        }).collect(Collectors.toList());

        return Result.success(result);
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
