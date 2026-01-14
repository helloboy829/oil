-- 创建数据库
CREATE DATABASE IF NOT EXISTS oil_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE oil_system;

-- 1. 商品分类表
CREATE TABLE `product_category` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `sort` INT DEFAULT 0 COMMENT '排序',
  `deleted` TINYINT DEFAULT 0 COMMENT '删除标记',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 2. 商品表
CREATE TABLE `product` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `category_id` BIGINT NOT NULL COMMENT '分类ID',
  `name` VARCHAR(100) NOT NULL COMMENT '商品名称',
  `code` VARCHAR(50) NOT NULL UNIQUE COMMENT '商品编码（二维码内容）',
  `spec` VARCHAR(100) COMMENT '规格型号',
  `unit` VARCHAR(20) DEFAULT '瓶' COMMENT '单位',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `stock` INT DEFAULT 0 COMMENT '库存数量',
  `qrcode_path` VARCHAR(255) COMMENT '二维码图片路径',
  `description` TEXT COMMENT '商品描述',
  `deleted` TINYINT DEFAULT 0 COMMENT '删除标记',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 3. 客户表
CREATE TABLE `customer` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '客户ID',
  `name` VARCHAR(100) NOT NULL COMMENT '客户姓名',
  `phone` VARCHAR(20) COMMENT '联系电话',
  `company` VARCHAR(100) COMMENT '公司名称',
  `address` VARCHAR(255) COMMENT '地址',
  `is_monthly` TINYINT DEFAULT 0 COMMENT '是否月结客户 0-否 1-是',
  `credit_limit` DECIMAL(10,2) DEFAULT 0 COMMENT '信用额度',
  `balance` DECIMAL(10,2) DEFAULT 0 COMMENT '当前欠款',
  `remark` TEXT COMMENT '备注',
  `deleted` TINYINT DEFAULT 0 COMMENT '删除标记',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户表';
