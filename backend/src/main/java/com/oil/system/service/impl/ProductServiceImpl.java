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
    public String generateQrCode(Long productId) {
        Product product = getById(productId);
        if (product != null) {
            String qrCodePath = QrCodeUtil.generateQrCode(product.getCode(), qrcodeSavePath);
            product.setQrcodePath(qrCodePath);  // 注意：实体类中字段是qrcodePath，不是qrCodePath
            updateById(product);
            return qrCodePath;
        }
        return null;
    }
}
