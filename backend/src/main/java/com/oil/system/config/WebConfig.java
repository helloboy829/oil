package com.oil.system.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${qrcode.save-path}")
    private String qrCodeSavePath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 映射二维码图片路径
        registry.addResourceHandler("/qrcodes/**")
                .addResourceLocations("file:" + qrCodeSavePath);
    }
}
