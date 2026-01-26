-- ==========================================
-- 为订单明细表添加缺失字段
-- 执行方法：
-- docker exec -i oil-mysql mysql -uroot -p123456 oil_system < add-order-item-columns.sql
-- ==========================================

USE oil_system;

-- 添加商品编码字段（如果不存在）
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM information_schema.columns
WHERE table_schema = 'oil_system' AND table_name = 'order_item' AND column_name = 'product_code';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `order_item` ADD COLUMN `product_code` VARCHAR(100) COMMENT ''商品编码'' AFTER `product_name`', 'SELECT ''product_code already exists'' AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加商品规格字段（如果不存在）
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM information_schema.columns
WHERE table_schema = 'oil_system' AND table_name = 'order_item' AND column_name = 'product_spec';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `order_item` ADD COLUMN `product_spec` VARCHAR(100) COMMENT ''商品规格'' AFTER `product_code`', 'SELECT ''product_spec already exists'' AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加单位字段（如果不存在）
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM information_schema.columns
WHERE table_schema = 'oil_system' AND table_name = 'order_item' AND column_name = 'unit';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `order_item` ADD COLUMN `unit` VARCHAR(20) DEFAULT ''瓶'' COMMENT ''单位'' AFTER `product_spec`', 'SELECT ''unit already exists'' AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '订单明细表字段检查完成！' AS message;
