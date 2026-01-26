-- ==========================================
-- 修复数据库表结构不匹配问题
-- 执行方法：
-- docker exec -i oil-mysql mysql -uroot -p123456 oil_system < fix-database-schema.sql
-- ==========================================

USE oil_system;

-- 1. 创建商品分类表（如果不存在）
CREATE TABLE IF NOT EXISTS `product_category` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '分类ID',
    `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记：0-未删除，1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_name (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 2. 为order_item表添加deleted字段（如果不存在）
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists FROM information_schema.columns
WHERE table_schema = 'oil_system' AND table_name = 'order_item' AND column_name = 'deleted';
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `order_item` ADD COLUMN `deleted` TINYINT DEFAULT 0 COMMENT ''删除标记：0-未删除，1-已删除''', 'SELECT ''deleted already exists'' AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '数据库表结构修复完成！' AS message;
