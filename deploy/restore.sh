#!/bin/bash
# ==========================================
# 数据库恢复脚本
# ==========================================

# 配置
CONTAINER_NAME="oil-mysql"
DB_NAME="oil_system"
DB_USER="root"
DB_PASSWORD="123456"

# 检查参数
if [ -z "$1" ]; then
    echo "用法: ./restore.sh <备份文件路径>"
    echo "示例: ./restore.sh ./data/backups/oil_system_20240101_120000.sql.gz"
    echo ""
    echo "可用的备份文件:"
    ls -lh ./data/backups/*.sql.gz 2>/dev/null || echo "暂无备份文件"
    exit 1
fi

BACKUP_FILE=$1

# 检查备份文件是否存在
if [ ! -f "$BACKUP_FILE" ]; then
    echo "错误: 备份文件不存在: $BACKUP_FILE"
    exit 1
fi

echo "准备恢复数据库: $DB_NAME"
echo "备份文件: $BACKUP_FILE"
echo "恢复时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 确认操作
read -p "警告: 此操作将覆盖现有数据库！是否继续? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

# 解压备份文件（如果是.gz格式）
if [[ $BACKUP_FILE == *.gz ]]; then
    echo "正在解压备份文件..."
    TEMP_SQL="${BACKUP_FILE%.gz}"
    gunzip -c $BACKUP_FILE > $TEMP_SQL
    SQL_FILE=$TEMP_SQL
else
    SQL_FILE=$BACKUP_FILE
fi

# 恢复数据库
echo "正在恢复数据库..."
docker exec -i $CONTAINER_NAME mysql -u$DB_USER -p$DB_PASSWORD $DB_NAME < $SQL_FILE

# 检查恢复是否成功
if [ $? -eq 0 ]; then
    echo "数据库恢复成功！"

    # 删除临时解压文件
    if [[ $BACKUP_FILE == *.gz ]]; then
        rm -f $TEMP_SQL
    fi
else
    echo "数据库恢复失败！"
    exit 1
fi

echo "恢复完成！"
