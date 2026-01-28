#!/bin/bash
# ==========================================
# 数据迁移脚本：从Docker volumes迁移到本地目录
# ==========================================

echo "=========================================="
echo "数据迁移工具"
echo "从Docker volumes迁移到本地目录"
echo "=========================================="
echo ""

# 检查是否有旧的volumes
echo "检查现有Docker volumes..."
MYSQL_VOLUME=$(docker volume ls -q | grep mysql-data)
QRCODE_VOLUME=$(docker volume ls -q | grep qrcode-data)
LOGS_VOLUME=$(docker volume ls -q | grep backend-logs)
SSL_VOLUME=$(docker volume ls -q | grep ssl-certs)

if [ -z "$MYSQL_VOLUME" ] && [ -z "$QRCODE_VOLUME" ] && [ -z "$LOGS_VOLUME" ]; then
    echo "未发现旧的Docker volumes，可能是首次部署或已经迁移"
    echo ""
    read -p "是否继续创建数据目录? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "操作已取消"
        exit 0
    fi
else
    echo "发现以下volumes:"
    [ -n "$MYSQL_VOLUME" ] && echo "  - $MYSQL_VOLUME (MySQL数据)"
    [ -n "$QRCODE_VOLUME" ] && echo "  - $QRCODE_VOLUME (二维码图片)"
    [ -n "$LOGS_VOLUME" ] && echo "  - $LOGS_VOLUME (日志文件)"
    [ -n "$SSL_VOLUME" ] && echo "  - $SSL_VOLUME (SSL证书)"
    echo ""
fi

# 确认操作
read -p "是否开始迁移? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

# 停止服务
echo ""
echo "步骤1: 停止Docker服务..."
docker-compose down
echo "服务已停止"

# 创建数据目录
echo ""
echo "步骤2: 创建本地数据目录..."
mkdir -p data/mysql data/qrcodes data/logs data/ssl data/backups
echo "目录创建完成"

# 迁移MySQL数据
if [ -n "$MYSQL_VOLUME" ]; then
    echo ""
    echo "步骤3: 迁移MySQL数据..."
    docker run --rm \
        -v ${MYSQL_VOLUME}:/from \
        -v $(pwd)/data/mysql:/to \
        alpine sh -c "cd /from && cp -av . /to"
    echo "MySQL数据迁移完成"
else
    echo ""
    echo "步骤3: 跳过MySQL数据迁移（volume不存在）"
fi

# 迁移二维码数据
if [ -n "$QRCODE_VOLUME" ]; then
    echo ""
    echo "步骤4: 迁移二维码图片..."
    docker run --rm \
        -v ${QRCODE_VOLUME}:/from \
        -v $(pwd)/data/qrcodes:/to \
        alpine sh -c "cd /from && cp -av . /to"
    echo "二维码数据迁移完成"
else
    echo ""
    echo "步骤4: 跳过二维码数据迁移（volume不存在）"
fi

# 迁移日志数据
if [ -n "$LOGS_VOLUME" ]; then
    echo ""
    echo "步骤5: 迁移日志文件..."
    docker run --rm \
        -v ${LOGS_VOLUME}:/from \
        -v $(pwd)/data/logs:/to \
        alpine sh -c "cd /from && cp -av . /to"
    echo "日志数据迁移完成"
else
    echo ""
    echo "步骤5: 跳过日志数据迁移（volume不存在）"
fi

# 迁移SSL证书
if [ -n "$SSL_VOLUME" ]; then
    echo ""
    echo "步骤6: 迁移SSL证书..."
    docker run --rm \
        -v ${SSL_VOLUME}:/from \
        -v $(pwd)/data/ssl:/to \
        alpine sh -c "cd /from && cp -av . /to"
    echo "SSL证书迁移完成"
else
    echo ""
    echo "步骤6: 跳过SSL证书迁移（volume不存在）"
fi

# 设置权限
echo ""
echo "步骤7: 设置目录权限..."
chmod -R 755 data/
chmod 700 data/mysql
echo "权限设置完成"

# 显示迁移结果
echo ""
echo "=========================================="
echo "迁移完成！数据目录大小："
du -sh data/*
echo "=========================================="
echo ""

# 询问是否删除旧volumes
if [ -n "$MYSQL_VOLUME" ] || [ -n "$QRCODE_VOLUME" ] || [ -n "$LOGS_VOLUME" ] || [ -n "$SSL_VOLUME" ]; then
    echo "旧的Docker volumes仍然存在"
    read -p "是否删除旧volumes以释放空间? (yes/no): " delete_confirm
    if [ "$delete_confirm" = "yes" ]; then
        [ -n "$MYSQL_VOLUME" ] && docker volume rm $MYSQL_VOLUME
        [ -n "$QRCODE_VOLUME" ] && docker volume rm $QRCODE_VOLUME
        [ -n "$LOGS_VOLUME" ] && docker volume rm $LOGS_VOLUME
        [ -n "$SSL_VOLUME" ] && docker volume rm $SSL_VOLUME
        echo "旧volumes已删除"
    else
        echo "保留旧volumes，你可以稍后手动删除"
    fi
fi

echo ""
echo "现在可以启动服务了："
echo "  docker-compose up -d --build"
