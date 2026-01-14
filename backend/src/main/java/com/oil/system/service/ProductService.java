package com.oil.system.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oil.system.entity.Product;

public interface ProductService extends IService<Product> {
    /**
     * 生成商品二维码
     */
    void generateQrCode(Long productId);
}
