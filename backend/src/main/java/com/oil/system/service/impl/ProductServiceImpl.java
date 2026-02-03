package com.oil.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.oil.system.entity.Product;
import com.oil.system.mapper.ProductMapper;
import com.oil.system.service.ProductService;
import com.oil.system.util.QrCodeUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class ProductServiceImpl extends ServiceImpl<ProductMapper, Product> implements ProductService {

    @Value("${qrcode.save-path}")
    private String qrcodeSavePath;

    @Override
    public boolean save(Product entity) {
        // 如果商品编码为空，自动生成
        if (entity.getCode() == null || entity.getCode().trim().isEmpty()) {
            entity.setCode(generateProductCode());
        }
        return super.save(entity);
    }

    @Override
    public String generateQrCode(Long productId) {
        Product product = getById(productId);
        if (product != null) {
            // 如果商品编码为空，先生成编码
            if (product.getCode() == null || product.getCode().trim().isEmpty()) {
                product.setCode(generateProductCode());
                updateById(product);
            }

            String qrCodePath = QrCodeUtil.generateQrCode(product.getCode(), qrcodeSavePath);
            product.setQrcodePath(qrCodePath);
            updateById(product);
            return qrCodePath;
        }
        return null;
    }

    /**
     * 生成商品编码：PROD + 时间戳 + 3位随机数
     * 例如：PROD20260203230659001
     */
    private String generateProductCode() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = (int) (Math.random() * 1000);
        return "PROD" + timestamp + String.format("%03d", random);
    }
}
