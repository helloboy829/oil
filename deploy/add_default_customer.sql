-- 添加默认客户 "xxx"，用于扫码开单时的临时客户
INSERT INTO customer (name, phone, company, is_monthly, credit_limit, balance, deleted, create_time, update_time)
VALUES ('xxx', '', '', 0, 0.00, 0.00, 0, NOW(), NOW())
ON DUPLICATE KEY UPDATE name = name;
