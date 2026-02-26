-- 给月结账单表添加 order_ids 字段，用于记录生成账单时关联的订单ID列表
ALTER TABLE monthly_bill ADD COLUMN order_ids TEXT NULL COMMENT '关联订单ID列表，JSON格式，如[1,2,3]';
