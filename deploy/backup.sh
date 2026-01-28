#!/bin/bash
# ==========================================
# 数据库自动备份脚本
# ==========================================

# 配置
BACKUP_DIR="./data/backups"
DATE=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="oil-mysql"
DB_NAME="oil_system"
DB_USER="root"
DB_PASSWORD="123456"

# 创建备份目录
mkdir -p $BACKUP_DIR

echo "开始备份数据库: $DB_NAME"
echo "备份时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 备份数据库
docker exec $CONTAINER_NAME mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/${DB_NAME}_${DATE}.sql

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "数据库备份成功"

    # 压缩备份文件
    gzip $BACKUP_DIR/${DB_NAME}_${DATE}.sql
    echo "备份文件已压缩: ${DB_NAME}_${DATE}.sql.gz"

    # 删除7天前的备份
    find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
    echo "已清理7天前的旧备份"

    # 显示当前备份列表
    echo ""
    echo "当前备份文件列表:"
    ls -lh $BACKUP_DIR/*.sql.gz 2>/dev/null || echo "暂无备份文件"
else
    echo "数据库备份失败！"
    exit 1
fi

echo "备份完成！"
