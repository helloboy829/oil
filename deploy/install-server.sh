#!/bin/bash

echo "=========================================="
echo "机油销售管理系统 - 服务器环境安装脚本"
echo "=========================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 用户或 sudo 运行此脚本"
    exit 1
fi

# 更新系统
echo "[1/7] 更新系统包..."
apt update && apt upgrade -y

# 安装 Java 11
echo "[2/7] 安装 Java 11..."
apt install openjdk-11-jdk -y
java -version

# 安装 MySQL 8
echo "[3/7] 安装 MySQL 8..."
apt install mysql-server -y

# 配置 MySQL
echo "[4/7] 配置 MySQL..."
mysql -e "CREATE DATABASE IF NOT EXISTS oil_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'oil'@'localhost' IDENTIFIED BY 'oil_password_2024';"
mysql -e "GRANT ALL PRIVILEGES ON oil_system.* TO 'oil'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
echo "MySQL 数据库 oil_system 创建成功"

# 安装 Nginx
echo "[5/7] 安装 Nginx..."
apt install nginx -y
systemctl enable nginx

# 安装 Node.js（用于前端构建）
echo "[6/7] 安装 Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install nodejs -y
node -v
npm -v

# 创建应用目录
echo "[7/7] 创建应用目录..."
mkdir -p /opt/oil-system/backend
mkdir -p /opt/oil-system/frontend
mkdir -p /opt/oil-system/qrcodes
mkdir -p /var/www/oil-frontend

echo "=========================================="
echo "环境安装完成！"
echo "=========================================="
echo "MySQL 数据库: oil_system"
echo "MySQL 用户: oil"
echo "MySQL 密码: oil_password_2024"
echo ""
echo "应用目录: /opt/oil-system"
echo "前端目录: /var/www/oil-frontend"
echo ""
echo "下一步："
echo "1. 运行 deploy-backend.sh 部署后端"
echo "2. 运行 deploy-frontend.sh 部署前端"
echo "=========================================="
