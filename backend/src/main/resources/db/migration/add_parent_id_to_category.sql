-- 数据库结构升级脚本
-- 1. 为分类表添加父子层级关系
-- 2. 为商品表和订单项表添加实际售卖价格字段

-- 1. 分类表添加parent_id字段支持树形分类结构
ALTER TABLE product_category
ADD COLUMN parent_id BIGINT NULL COMMENT '父分类ID，为NULL表示顶级分类' AFTER sort;

-- 为parent_id添加索引以优化树形查询性能
CREATE INDEX idx_parent_id ON product_category(parent_id);

-- 2. 商品表添加实际售卖价格字段
ALTER TABLE product
ADD COLUMN actual_price DECIMAL(10,2) NULL COMMENT '实际售卖价格，为空时使用price字段' AFTER price;

-- 3. 订单项表添加实际售卖价格字段（记录历史成交价）
ALTER TABLE order_item
ADD COLUMN actual_price DECIMAL(10,2) NULL COMMENT '实际成交价格，记录历史售价' AFTER price;
