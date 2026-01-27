#!/bin/bash
# 生成自签名SSL证书脚本

# 创建证书目录
mkdir -p /etc/nginx/ssl

# 生成私钥和证书（有效期10年）
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx-selfsigned.key \
  -out /etc/nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Oil System/OU=IT/CN=oil-system"

# 设置权限
chmod 600 /etc/nginx/ssl/nginx-selfsigned.key
chmod 644 /etc/nginx/ssl/nginx-selfsigned.crt

echo "SSL证书生成完成！"
ls -lh /etc/nginx/ssl/
