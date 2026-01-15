#!/bin/bash

echo "=========================================="
echo "部署前端服务"
echo "=========================================="

# 配置变量
FRONTEND_DIR="/var/www/oil-frontend"
NGINX_CONF="/etc/nginx/sites-available/oil-system"

# 检查 dist 目录是否存在
if [ ! -d "dist" ]; then
    echo "错误: 找不到 dist 目录"
    echo "请先在本地运行 npm run build，然后上传 dist 目录到当前目录"
    exit 1
fi

# 清理旧文件
echo "[1/4] 清理旧文件..."
rm -rf $FRONTEND_DIR/*

# 复制前端文件
echo "[2/4] 复制前端文件到 $FRONTEND_DIR..."
cp -r dist/* $FRONTEND_DIR/

# 创建 Nginx 配置
echo "[3/4] 配置 Nginx..."
cat > $NGINX_CONF <<'EOF'
server {
    listen 80;
    server_name _;  # 替换为你的域名

    client_max_body_size 10M;

    # 前端静态文件
    location / {
        root /var/www/oil-frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 后端 API 代理
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;
}
EOF

# 启用站点
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/oil-system

# 测试 Nginx 配置
echo "[4/4] 测试并重启 Nginx..."
nginx -t

if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "=========================================="
    echo "前端服务部署成功！"
    echo "=========================================="
    echo "访问地址: http://your-server-ip"
    echo "H5扫码页面: http://your-server-ip/scan"
    echo ""
    echo "常用命令:"
    echo "  查看 Nginx 状态: systemctl status nginx"
    echo "  查看 Nginx 日志: tail -f /var/log/nginx/error.log"
    echo "  重启 Nginx: systemctl restart nginx"
    echo "=========================================="
else
    echo "Nginx 配置错误，请检查配置文件"
    exit 1
fi
