-- ==========================================
-- 商品分类功能迁移脚本
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

-- 2. 插入默认分类数据
INSERT INTO `product_category` (`name`, `sort`) VALUES
('蓄电池', 1),
('机油', 2),
('轮胎', 3)
ON DUPLICATE KEY UPDATE name=name;

-- 3. 为商品表添加分类ID字段（如果不存在）
ALTER TABLE `product`
ADD COLUMN IF NOT EXISTS `category_id` BIGINT COMMENT '分类ID' AFTER `id`,
ADD INDEX IF NOT EXISTS `idx_category_id` (`category_id`);

-- 4. 为商品表添加成本字段（如果不存在）
ALTER TABLE `product`
ADD COLUMN IF NOT EXISTS `cost` DECIMAL(10,2) COMMENT '成本价' AFTER `price`;

-- 5. 为月结账单表添加类别ID字段（如果不存在）
ALTER TABLE `monthly_bill`
ADD COLUMN IF NOT EXISTS `category_ids` VARCHAR(500) COMMENT '筛选的类别ID列表（JSON格式）' AFTER `order_ids`;

-- 6. 更新现有商品的默认分类为"蓄电池"
UPDATE `product`
SET `category_id` = (SELECT id FROM `product_category` WHERE name = '蓄电池' LIMIT 1)
WHERE `category_id` IS NULL AND `deleted` = 0;

COMMIT;

-- ==========================================
-- 迁移完成
-- ==========================================
