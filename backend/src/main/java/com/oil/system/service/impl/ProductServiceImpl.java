package com.oil.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.entity.Product;
import com.oil.system.mapper.ProductMapper;
import com.oil.system.service.ProductService;
import com.oil.system.util.QrCodeUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ProductServiceImpl extends ServiceImpl<ProductMapper, Product> implements ProductService {

    @Value("${qrcode.save-path}")
    private String qrcodeSavePath;

    @Override
    public void generateQrCode(Long productId) {
        Product product = getById(productId);
        if (product != null) {
            String qrcodePath = QrCodeUtil.generateQrCode(product.getCode(), qrcodeSavePath);
            product.setQrcodePath(qrcodePath);
            updateById(product);
        }
    }
}
