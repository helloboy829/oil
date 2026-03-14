-- 修复商品分类表的字符编码问题
-- 确保使用 UTF-8 编码插入数据

USE oil_system;

-- 删除所有现有的分类数据
DELETE FROM product_category;

-- 重新插入正确编码的三个类别
INSERT INTO product_category (name, sort, deleted, create_time, update_time) VALUES
('蓄电池', 1, 0, NOW(), NOW()),
('机油', 2, 0, NOW(), NOW()),
('轮胎', 3, 0, NOW(), NOW());

-- 验证插入结果
SELECT id, name, sort, deleted FROM product_category WHERE deleted = 0 ORDER BY sort;
