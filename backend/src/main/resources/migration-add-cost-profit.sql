-- 成本和利润功能数据库迁移脚本
-- 执行日期: 2026-03-14
-- 功能: 添加商品成本、订单明细成本和利润字段

-- 1. 为 product 表添加成本字段
ALTER TABLE product
ADD COLUMN cost DECIMAL(10,2) DEFAULT NULL COMMENT '成本价（可选，NULL表示未录入）';

-- 2. 为 order_item 表添加成本和利润字段
ALTER TABLE order_item
ADD COLUMN cost DECIMAL(10,2) DEFAULT NULL COMMENT '成本价快照（可选）',
ADD COLUMN profit DECIMAL(10,2) DEFAULT NULL COMMENT '单品利润 = (price - cost) * quantity';

-- 完成提示
SELECT '数据库迁移完成：成本和利润字段已添加' AS message;
