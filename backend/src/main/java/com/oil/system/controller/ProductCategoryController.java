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
     * 获取所有分类列表（含商品数量统计，树形结构）
     */
    @GetMapping("/listWithCount")
    public Result<List<CategoryWithCountDTO>> listWithCount() {
        // 获取所有类别
        LambdaQueryWrapper<ProductCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(ProductCategory::getSort);
        List<ProductCategory> categories = categoryService.list(wrapper);

        // 统计每个类别下的商品库存总量
        List<CategoryWithCountDTO> allCategories = categories.stream().map(category -> {
            // 查询该类别下所有商品
            LambdaQueryWrapper<Product> productWrapper = new LambdaQueryWrapper<>();
            productWrapper.eq(Product::getCategoryId, category.getId())
                         .eq(Product::getDeleted, 0);
            List<Product> products = productService.list(productWrapper);

            // 计算库存总和
            long totalStock = products.stream()
                    .mapToInt(p -> p.getStock() != null ? p.getStock() : 0)
                    .sum();

            // 构建DTO
            return new CategoryWithCountDTO(
                    category.getId(),
                    category.getName(),
                    category.getSort(),
                    category.getParentId(),
                    totalStock
            );
        }).collect(Collectors.toList());

        // 构建树形结构
        List<CategoryWithCountDTO> tree = buildTree(allCategories, null);

        return Result.success(tree);
    }

    /**
     * 递归构建树形结构
     */
    private List<CategoryWithCountDTO> buildTree(List<CategoryWithCountDTO> allCategories, Long parentId) {
        return allCategories.stream()
                .filter(category -> {
                    if (parentId == null) {
                        return category.getParentId() == null;
                    }
                    return parentId.equals(category.getParentId());
                })
                .peek(category -> {
                    List<CategoryWithCountDTO> children = buildTree(allCategories, category.getId());
                    category.setChildren(children.isEmpty() ? null : children);
                })
                .collect(Collectors.toList());
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
