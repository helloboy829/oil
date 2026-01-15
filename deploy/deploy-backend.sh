#!/bin/bash

echo "=========================================="
echo "部署后端服务"
echo "=========================================="

# 配置变量
APP_NAME="oil-system"
APP_DIR="/opt/oil-system/backend"
JAR_NAME="oil-system-1.0.0.jar"
SERVICE_NAME="oil-system"

# 检查 JAR 文件是否存在
if [ ! -f "$JAR_NAME" ]; then
    echo "错误: 找不到 $JAR_NAME"
    echo "请先在本地运行 mvn clean package，然后上传 JAR 文件到当前目录"
    exit 1
fi

# 停止旧服务
echo "[1/5] 停止旧服务..."
systemctl stop $SERVICE_NAME 2>/dev/null || true

# 复制 JAR 文件
echo "[2/5] 复制 JAR 文件到 $APP_DIR..."
cp $JAR_NAME $APP_DIR/

# 创建 systemd 服务
echo "[3/5] 创建 systemd 服务..."
cat > /etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=Oil System Backend Service
After=mysql.service
Wants=mysql.service

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/java -Xms256m -Xmx512m -jar $APP_DIR/$JAR_NAME
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# 重载 systemd
echo "[4/5] 重载 systemd..."
systemctl daemon-reload

# 启动服务
echo "[5/5] 启动服务..."
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# 检查状态
sleep 5
if systemctl is-active --quiet $SERVICE_NAME; then
    echo "=========================================="
    echo "后端服务部署成功！"
    echo "=========================================="
    echo "服务状态: $(systemctl is-active $SERVICE_NAME)"
    echo "服务端口: 8080"
    echo ""
    echo "常用命令:"
    echo "  查看状态: systemctl status $SERVICE_NAME"
    echo "  查看日志: journalctl -u $SERVICE_NAME -f"
    echo "  重启服务: systemctl restart $SERVICE_NAME"
    echo "  停止服务: systemctl stop $SERVICE_NAME"
    echo "=========================================="
else
    echo "=========================================="
    echo "后端服务启动失败！"
    echo "=========================================="
    echo "请查看日志: journalctl -u $SERVICE_NAME -n 50"
    exit 1
fi
