-- ==========================================
-- 为订单明细表添加缺失字段
-- 执行方法：
-- docker exec -i oil-mysql mysql -uroot -p123456 oil_system < add-order-item-columns.sql
-- ==========================================

USE oil_system;

-- 添加商品编码字段
ALTER TABLE `order_item` ADD COLUMN `product_code` VARCHAR(100) COMMENT '商品编码' AFTER `product_name`;

-- 添加商品规格字段
ALTER TABLE `order_item` ADD COLUMN `product_spec` VARCHAR(100) COMMENT '商品规格' AFTER `product_code`;

-- 添加单位字段
ALTER TABLE `order_item` ADD COLUMN `unit` VARCHAR(20) DEFAULT '瓶' COMMENT '单位' AFTER `product_spec`;

SELECT '订单明细表字段添加成功！' AS message;
