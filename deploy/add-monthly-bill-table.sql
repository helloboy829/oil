-- ==========================================
-- 添加月结账单表
-- 执行方法：
-- docker exec -i oil-mysql mysql -uroot -p123456 oil_system < add-monthly-bill-table.sql
-- ==========================================

USE oil_system;

-- 月结账单表
CREATE TABLE IF NOT EXISTS `monthly_bill` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '账单ID',
    `bill_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '账单编号',
    `customer_id` BIGINT NOT NULL COMMENT '客户ID',
    `customer_name` VARCHAR(100) NOT NULL COMMENT '客户姓名',
    `bill_month` VARCHAR(20) NOT NULL COMMENT '账单月份（格式：YYYY-MM）',
    `total_amount` DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '账单总金额',
    `paid_amount` DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '已支付金额',
    `status` VARCHAR(20) DEFAULT '未结算' COMMENT '账单状态：未结算/已结算/部分结算',
    `settlement_date` DATE COMMENT '结算日期',
    `remark` VARCHAR(500) COMMENT '备注',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记：0-未删除，1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_bill_no (`bill_no`),
    INDEX idx_customer_id (`customer_id`),
    INDEX idx_bill_month (`bill_month`),
    INDEX idx_status (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='月结账单表';

SELECT '月结账单表创建成功！' AS message;
