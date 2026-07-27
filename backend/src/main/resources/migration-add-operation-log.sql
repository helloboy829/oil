-- 操作日志表
CREATE TABLE IF NOT EXISTS `operation_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `module` VARCHAR(50) NOT NULL COMMENT '操作模块：商品管理/客户管理/订单管理/月结账单/分类管理/用户管理',
  `action` VARCHAR(50) NOT NULL COMMENT '操作类型：新增/修改/删除/批量删除/登录/生成账单/结算/导出',
  `description` VARCHAR(500) COMMENT '操作描述',
  `operator_id` BIGINT COMMENT '操作人ID',
  `operator_name` VARCHAR(100) COMMENT '操作人名称',
  `target_id` VARCHAR(100) COMMENT '操作对象ID',
  `target_name` VARCHAR(200) COMMENT '操作对象名称',
  `request_ip` VARCHAR(50) COMMENT '请求IP',
  `request_method` VARCHAR(10) COMMENT '请求方法 GET/POST/PUT/DELETE',
  `request_url` VARCHAR(500) COMMENT '请求URL',
  `request_params` TEXT COMMENT '请求参数(JSON)',
  `status` VARCHAR(20) DEFAULT '成功' COMMENT '操作结果：成功/失败',
  `error_msg` VARCHAR(1000) COMMENT '错误信息',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_module` (`module`),
  KEY `idx_operator_id` (`operator_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';
