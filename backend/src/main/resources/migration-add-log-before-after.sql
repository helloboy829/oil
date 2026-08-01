-- 操作日志表增加变更前后数据字段
ALTER TABLE operation_log
  ADD COLUMN IF NOT EXISTS before_data TEXT COMMENT '操作前数据(JSON)',
  ADD COLUMN IF NOT EXISTS after_data TEXT COMMENT '操作后数据(JSON)';
