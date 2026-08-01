-- 操作日志表增加变更描述字段
ALTER TABLE operation_log ADD COLUMN change_description VARCHAR(2000) COMMENT '变更描述(自然语言)';
