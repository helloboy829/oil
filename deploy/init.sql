-- ==========================================
-- 机油销售管理系统 - 数据库初始化脚本
-- ==========================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS oil_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oil_system;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(100) NOT NULL COMMENT '密码（加密）',
    `nickname` VARCHAR(50) COMMENT '昵称',
    `phone` VARCHAR(20) COMMENT '手机号',
    `email` VARCHAR(100) COMMENT '邮箱',
    `role` VARCHAR(20) DEFAULT 'USER' COMMENT '角色：ADMIN/USER',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记：0-未删除，1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (`username`),
    INDEX idx_phone (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 客户表
CREATE TABLE IF NOT EXISTS `customer` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '客户ID',
    `name` VARCHAR(100) NOT NULL COMMENT '客户姓名',
    `phone` VARCHAR(20) COMMENT '手机号',
    `company` VARCHAR(200) COMMENT '公司名称',
    `address` VARCHAR(300) COMMENT '地址',
    `is_monthly` TINYINT DEFAULT 0 COMMENT '是否月结客户：0-否，1-是',
    `credit_limit` DECIMAL(10,2) DEFAULT 0 COMMENT '信用额度',
    `balance` DECIMAL(10,2) DEFAULT 0 COMMENT '当前余额',
    `remark` VARCHAR(500) COMMENT '备注',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记：0-未删除，1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (`name`),
    INDEX idx_phone (`phone`),
    INDEX idx_monthly (`is_monthly`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户表';

-- 商品表
CREATE TABLE IF NOT EXISTS `product` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '商品ID',
    `name` VARCHAR(200) NOT NULL COMMENT '商品名称',
    `category` VARCHAR(50) COMMENT '分类',
    `brand` VARCHAR(100) COMMENT '品牌',
    `specification` VARCHAR(100) COMMENT '规格',
    `unit` VARCHAR(20) DEFAULT '瓶' COMMENT '单位',
    `price` DECIMAL(10,2) NOT NULL COMMENT '销售价格',
    `cost` DECIMAL(10,2) COMMENT '成本价格',
    `stock` INT DEFAULT 0 COMMENT '库存数量',
    `barcode` VARCHAR(100) COMMENT '条形码',
    `qrcode` VARCHAR(200) COMMENT '二维码路径',
    `image` VARCHAR(300) COMMENT '商品图片',
    `description` TEXT COMMENT '商品描述',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记：0-未删除，1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (`name`),
    INDEX idx_barcode (`barcode`),
    INDEX idx_category (`category`),
    INDEX idx_status (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 订单表
CREATE TABLE IF NOT EXISTS `orders` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '订单ID',
    `order_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
    `customer_id` BIGINT COMMENT '客户ID',
    `customer_name` VARCHAR(100) COMMENT '客户姓名',
    `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    `payment_type` VARCHAR(20) COMMENT '支付方式：现金/微信/支付宝/月结',
    `payment_status` VARCHAR(20) DEFAULT '未结算' COMMENT '结算状态：已结算/未结算',
    `order_status` VARCHAR(20) DEFAULT '已完成' COMMENT '订单状态',
    `remark` VARCHAR(500) COMMENT '备注',
    `operator_id` BIGINT COMMENT '操作员ID',
    `operator_name` VARCHAR(50) COMMENT '操作员姓名',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记：0-未删除，1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_order_no (`order_no`),
    INDEX idx_customer_id (`customer_id`),
    INDEX idx_customer_name (`customer_name`),
    INDEX idx_payment_status (`payment_status`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 订单明细表
CREATE TABLE IF NOT EXISTS `order_item` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '订单明细ID',
    `order_id` BIGINT NOT NULL COMMENT '订单ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
    `price` DECIMAL(10,2) NOT NULL COMMENT '商品单价',
    `quantity` INT NOT NULL COMMENT '购买数量',
    `subtotal` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_order_id (`order_id`),
    INDEX idx_product_id (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 库存记录表
CREATE TABLE IF NOT EXISTS `stock_record` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '记录ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
    `type` VARCHAR(20) NOT NULL COMMENT '类型：入库/出库',
    `quantity` INT NOT NULL COMMENT '数量',
    `before_stock` INT COMMENT '变动前库存',
    `after_stock` INT COMMENT '变动后库存',
    `remark` VARCHAR(500) COMMENT '备注',
    `operator_id` BIGINT COMMENT '操作员ID',
    `operator_name` VARCHAR(50) COMMENT '操作员姓名',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_product_id (`product_id`),
    INDEX idx_type (`type`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存记录表';

-- 插入默认管理员账户（密码: admin123）
INSERT INTO `user` (`username`, `password`, `nickname`, `role`, `status`)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', 'ADMIN', 1)
ON DUPLICATE KEY UPDATE username=username;

-- 插入测试商品数据
INSERT INTO `product` (`name`, `category`, `brand`, `specification`, `unit`, `price`, `cost`, `stock`, `status`) VALUES
('壳牌 Helix Ultra 5W-40 全合成机油', '全合成', '壳牌', '4L', '瓶', 298.00, 180.00, 50, 1),
('美孚 1号 0W-40 全合成机油', '全合成', '美孚', '4L', '瓶', 368.00, 220.00, 30, 1),
('嘉实多 磁护 5W-40 全合成机油', '全合成', '嘉实多', '4L', '瓶', 328.00, 200.00, 40, 1),
('长城 金吉星 5W-30 半合成机油', '半合成', '长城', '4L', '瓶', 168.00, 100.00, 60, 1),
('昆仑 天润 10W-40 矿物质机油', '矿物质', '昆仑', '4L', '瓶', 88.00, 50.00, 80, 1)
ON DUPLICATE KEY UPDATE name=name;

-- 插入测试客户数据
INSERT INTO `customer` (`name`, `phone`, `company`, `is_monthly`) VALUES
('张三', '13800138001', '顺丰速运', 1),
('李四', '13800138002', '德邦物流', 1),
('王五', '13800138003', NULL, 0)
ON DUPLICATE KEY UPDATE name=name;

COMMIT;

-- ==========================================
-- 初始化完成
-- ==========================================
