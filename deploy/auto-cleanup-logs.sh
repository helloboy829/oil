#!/bin/bash

# ==========================================
# 日志自动清理脚本（用于 crontab）
# ==========================================

set -e

LOG_FILE="/var/log/oil-log-cleanup.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

log_message "========== 开始清理日志 =========="

# 1. 清理 Docker 容器日志（超过 30 天）
log_message "清理 Docker 容器日志..."
truncate -s 0 $(docker inspect --format='{{.LogPath}}' oil-mysql 2>/dev/null) 2>/dev/null || true
truncate -s 0 $(docker inspect --format='{{.LogPath}}' oil-backend 2>/dev/null) 2>/dev/null || true
truncate -s 0 $(docker inspect --format='{{.LogPath}}' oil-frontend 2>/dev/null) 2>/dev/null || true

# 2. 清理后端应用日志（超过 30 天的压缩文件）
log_message "清理后端应用日志..."
docker exec oil-backend find /app/logs -name "*.log.gz" -mtime +30 -delete 2>/dev/null || true

# 3. 清理备份日志（超过 60 天）
log_message "清理备份日志..."
find /root/oil-logs-backup -name "*.tar.gz" -mtime +60 -delete 2>/dev/null || true

# 4. 显示清理后的磁盘使用情况
log_message "当前磁盘使用情况:"
df -h / | tee -a ${LOG_FILE}

log_message "========== 日志清理完成 =========="
