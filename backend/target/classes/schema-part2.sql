-- 4. 订单表
CREATE TABLE `orders` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '订单编号',
  `customer_id` BIGINT COMMENT '客户ID',
  `customer_name` VARCHAR(100) COMMENT '客户姓名',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
  `payment_type` VARCHAR(20) COMMENT '支付方式：现金、微信、支付宝、月结',
  `payment_status` VARCHAR(20) DEFAULT '未支付' COMMENT '支付状态：未支付、已支付、部分支付',
  `order_status` VARCHAR(20) DEFAULT '待确认' COMMENT '订单状态：待确认、已完成、已取消',
  `remark` TEXT COMMENT '备注',
  `deleted` TINYINT DEFAULT 0 COMMENT '删除标记',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 5. 订单明细表
CREATE TABLE `order_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(100) NOT NULL COMMENT '商品名称',
  `product_code` VARCHAR(50) NOT NULL COMMENT '商品编码',
  `product_spec` VARCHAR(100) COMMENT '规格型号',
  `unit` VARCHAR(20) COMMENT '单位',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `quantity` INT NOT NULL COMMENT '数量',
  `subtotal` DECIMAL(10,2) NOT NULL COMMENT '小计',
  `deleted` TINYINT DEFAULT 0 COMMENT '删除标记',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 6. 月结账单表
CREATE TABLE `monthly_bill` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '账单ID',
  `bill_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '账单编号',
  `customer_id` BIGINT NOT NULL COMMENT '客户ID',
  `customer_name` VARCHAR(100) NOT NULL COMMENT '客户姓名',
  `bill_month` VARCHAR(7) NOT NULL COMMENT '账单月份 YYYY-MM',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '账单总金额',
  `paid_amount` DECIMAL(10,2) DEFAULT 0 COMMENT '已支付金额',
  `status` VARCHAR(20) DEFAULT '未结算' COMMENT '状态：未结算、已结算、部分结算',
  `settlement_date` DATE COMMENT '结算日期',
  `remark` TEXT COMMENT '备注',
  `deleted` TINYINT DEFAULT 0 COMMENT '删除标记',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_bill_month` (`bill_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='月结账单表';

-- 7. 用户表（商家管理员）
CREATE TABLE `sys_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码',
  `nickname` VARCHAR(50) COMMENT '昵称',
  `phone` VARCHAR(20) COMMENT '手机号',
  `status` TINYINT DEFAULT 1 COMMENT '状态 0-禁用 1-启用',
  `deleted` TINYINT DEFAULT 0 COMMENT '删除标记',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 插入默认管理员账号（密码：123456）
INSERT INTO `sys_user` (`username`, `password`, `nickname`)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '管理员');

-- 插入测试数据
INSERT INTO `product_category` (`name`, `sort`) VALUES
('机油', 1),
('润滑油', 2),
('添加剂', 3);

INSERT INTO `product` (`category_id`, `name`, `code`, `spec`, `unit`, `price`, `stock`) VALUES
(1, '壳牌喜力HX8 5W-30', 'P001', '4L', '瓶', 298.00, 100),
(1, '美孚1号 0W-40', 'P002', '4L', '瓶', 458.00, 80),
(1, '嘉实多极护 5W-40', 'P003', '4L', '瓶', 368.00, 90),
(2, '长城尊龙柴油机油', 'P004', '18L', '桶', 680.00, 50);
