#!/bin/bash

# ==========================================
# 日志管理脚本
# ==========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志目录
LOG_DIR="/var/lib/docker/volumes"
BACKUP_DIR="/oil-logs-backup"

# 显示菜单
show_menu() {
    echo ""
    echo "=========================================="
    echo "         油品系统 - 日志管理工具"
    echo "=========================================="
    echo "1. 查看所有容器日志"
    echo "2. 查看后端应用日志"
    echo "3. 查看错误日志"
    echo "4. 实时监控日志"
    echo "5. 清理旧日志"
    echo "6. 备份日志"
    echo "7. 查看日志统计"
    echo "8. 搜索日志内容"
    echo "0. 退出"
    echo "=========================================="
    echo -n "请选择操作 [0-8]: "
}

# 1. 查看所有容器日志
view_all_logs() {
    echo -e "${GREEN}=== 所有容器日志 ===${NC}"
    echo ""
    echo "MySQL 日志 (最后 50 行):"
    docker logs --tail 50 oil-mysql
    echo ""
    echo "后端日志 (最后 50 行):"
    docker logs --tail 50 oil-backend
    echo ""
    echo "前端日志 (最后 50 行):"
    docker logs --tail 50 oil-frontend
}

# 2. 查看后端应用日志
view_backend_logs() {
    echo -e "${GREEN}=== 后端应用日志 ===${NC}"
    echo ""
    echo "1. 查看所有日志"
    echo "2. 查看错误日志"
    echo "3. 查看今天的日志"
    echo -n "请选择 [1-3]: "
    read choice

    case $choice in
        1)
            docker exec oil-backend cat /app/logs/oil-system.log | tail -100
            ;;
        2)
            docker exec oil-backend cat /app/logs/oil-system-error.log 2>/dev/null || echo "暂无错误日志"
            ;;
        3)
            TODAY=$(date +%Y-%m-%d)
            docker exec oil-backend cat /app/logs/oil-system-${TODAY}.*.log 2>/dev/null || echo "今天暂无日志"
            ;;
    esac
}

# 3. 查看错误日志
view_error_logs() {
    echo -e "${RED}=== 错误日志 ===${NC}"
    echo ""
    docker exec oil-backend cat /app/logs/oil-system-error.log 2>/dev/null | tail -50 || echo "暂无错误日志"
}

# 4. 实时监控日志
monitor_logs() {
    echo -e "${GREEN}=== 实时监控日志 (Ctrl+C 退出) ===${NC}"
    echo ""
    echo "1. 监控后端日志"
    echo "2. 监控 MySQL 日志"
    echo "3. 监控前端日志"
    echo "4. 监控所有日志"
    echo -n "请选择 [1-4]: "
    read choice

    case $choice in
        1)
            docker logs -f oil-backend
            ;;
        2)
            docker logs -f oil-mysql
            ;;
        3)
            docker logs -f oil-frontend
            ;;
        4)
            docker-compose logs -f
            ;;
    esac
}

# 5. 清理旧日志
clean_old_logs() {
    echo -e "${YELLOW}=== 清理旧日志 ===${NC}"
    echo ""
    echo "警告：此操作将删除 30 天前的日志文件"
    echo -n "确认继续？(y/n): "
    read confirm

    if [ "$confirm" = "y" ]; then
        echo "正在清理旧日志..."
        docker exec oil-backend find /app/logs -name "*.log.gz" -mtime +30 -delete 2>/dev/null || true
        echo -e "${GREEN}清理完成！${NC}"
    else
        echo "已取消"
    fi
}

# 6. 备份日志
backup_logs() {
    echo -e "${GREEN}=== 备份日志 ===${NC}"
    echo ""

    # 创建备份目录
    mkdir -p ${BACKUP_DIR}

    BACKUP_FILE="${BACKUP_DIR}/logs-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

    echo "正在备份日志到: ${BACKUP_FILE}"

    # 备份后端日志
    docker exec oil-backend tar czf /tmp/backend-logs.tar.gz /app/logs 2>/dev/null
    docker cp oil-backend:/tmp/backend-logs.tar.gz ${BACKUP_FILE}
    docker exec oil-backend rm /tmp/backend-logs.tar.gz

    echo -e "${GREEN}备份完成！${NC}"
    echo "备份文件: ${BACKUP_FILE}"

    # 显示备份大小
    du -h ${BACKUP_FILE}
}

# 7. 查看日志统计
view_log_stats() {
    echo -e "${GREEN}=== 日志统计 ===${NC}"
    echo ""

    echo "Docker 容器日志大小:"
    docker ps -a --format "table {{.Names}}\t{{.Size}}"
    echo ""

    echo "后端应用日志统计:"
    docker exec oil-backend du -sh /app/logs 2>/dev/null || echo "无法获取"
    echo ""

    echo "日志文件列表:"
    docker exec oil-backend ls -lh /app/logs 2>/dev/null || echo "无法获取"
}

# 8. 搜索日志内容
search_logs() {
    echo -e "${GREEN}=== 搜索日志 ===${NC}"
    echo ""
    echo -n "请输入搜索关键词: "
    read keyword

    if [ -z "$keyword" ]; then
        echo "关键词不能为空"
        return
    fi

    echo ""
    echo "在后端日志中搜索 '${keyword}':"
    docker exec oil-backend grep -r "${keyword}" /app/logs 2>/dev/null | tail -20 || echo "未找到匹配内容"
}

# 主循环
main() {
    while true; do
        show_menu
        read choice

        case $choice in
            1)
                view_all_logs
                ;;
            2)
                view_backend_logs
                ;;
            3)
                view_error_logs
                ;;
            4)
                monitor_logs
                ;;
            5)
                clean_old_logs
                ;;
            6)
                backup_logs
                ;;
            7)
                view_log_stats
                ;;
            8)
                search_logs
                ;;
            0)
                echo "退出"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重试${NC}"
                ;;
        esac

        echo ""
        echo -n "按回车键继续..."
        read
    done
}

# 运行主程序
main
