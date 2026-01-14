package com.oil.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.oil.system.dto.Result;
import com.oil.system.entity.Product;
import com.oil.system.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/product")
@RequiredArgsConstructor
@CrossOrigin
public class ProductController {

    private final ProductService productService;

    /**
     * 分页查询商品
     */
    @GetMapping("/page")
    public Result<Page<Product>> page(@RequestParam(defaultValue = "1") Integer current,
                                       @RequestParam(defaultValue = "10") Integer size,
                                       @RequestParam(required = false) String name) {
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<>();
        if (name != null && !name.isEmpty()) {
            wrapper.like(Product::getName, name);
        }
        Page<Product> page = productService.page(new Page<>(current, size), wrapper);
        return Result.success(page);
    }

    /**
     * 根据编码查询商品
     */
    @GetMapping("/code/{code}")
    public Result<Product> getByCode(@PathVariable String code) {
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Product::getCode, code);
        Product product = productService.getOne(wrapper);
        return Result.success(product);
    }

    /**
     * 新增商品
     */
    @PostMapping
    public Result<Void> save(@RequestBody Product product) {
        productService.save(product);
        // 生成二维码
        productService.generateQrCode(product.getId());
        return Result.success();
    }

    /**
     * 更新商品
     */
    @PutMapping
    public Result<Void> update(@RequestBody Product product) {
        productService.updateById(product);
        return Result.success();
    }

    /**
     * 删除商品
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        productService.removeById(id);
        return Result.success();
    }

    /**
     * 生成商品二维码
     */
    @PostMapping("/qrcode/{id}")
    public Result<String> generateQrCode(@PathVariable Long id) {
        String qrCodePath = productService.generateQrCode(id);
        return Result.success(qrCodePath);
    }

    /**
     * 获取商品二维码
     */
    @GetMapping("/qrcode/{id}")
    public Result<String> getQrCode(@PathVariable Long id) {
        Product product = productService.getById(id);
        if (product == null) {
            return Result.error("商品不存在");
        }
        return Result.success(product.getQrcodePath());  // 注意：实体类字段是qrcodePath
    }
}
