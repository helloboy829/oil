package com.oil.system;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.oil.system.mapper")
public class OilSystemApplication {
    public static void main(String[] args) {
        SpringApplication.run(OilSystemApplication.class, args);
    }
}
