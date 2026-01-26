#!/bin/bash

# ==========================================
# HTTPS 部署脚本（自签名证书版本）
# ==========================================

set -e

echo "=========================================="
echo "    油品系统 - HTTPS 部署脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 停止当前运行的服务
echo -e "${YELLOW}步骤 1/7: 停止当前运行的服务...${NC}"
cd /root/oil
docker-compose down
echo -e "${GREEN}✓ 服务已停止${NC}"
echo ""

# 2. 拉取最新代码
echo -e "${YELLOW}步骤 2/7: 拉取最新代码...${NC}"
git pull
echo -e "${GREEN}✓ 代码已更新${NC}"
echo ""

# 3. 安装 Nginx
echo -e "${YELLOW}步骤 3/7: 安装 Nginx...${NC}"
if ! command -v nginx &> /dev/null; then
    yum install -y nginx
    echo -e "${GREEN}✓ Nginx 安装成功${NC}"
else
    echo -e "${GREEN}✓ Nginx 已安装${NC}"
fi
echo ""

# 4. 生成自签名证书
echo -e "${YELLOW}步骤 4/7: 生成自签名证书...${NC}"
mkdir -p /etc/nginx/ssl
if [ ! -f /etc/nginx/ssl/oil.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/oil.key \
      -out /etc/nginx/ssl/oil.crt \
      -subj "/C=CN/ST=Beijing/L=Beijing/O=Oil/CN=localhost"
    echo -e "${GREEN}✓ 证书生成成功${NC}"
else
    echo -e "${GREEN}✓ 证书已存在${NC}"
fi
echo ""

# 5. 配置 Nginx
echo -e "${YELLOW}步骤 5/7: 配置 Nginx...${NC}"
cp /root/oil/deploy/nginx-selfsigned.conf /etc/nginx/conf.d/oil.conf
nginx -t
echo -e "${GREEN}✓ Nginx 配置成功${NC}"
echo ""

# 6. 配置防火墙
echo -e "${YELLOW}步骤 6/7: 配置防火墙...${NC}"
firewall-cmd --permanent --add-service=https 2>/dev/null || echo "防火墙未运行或已配置"
firewall-cmd --reload 2>/dev/null || echo "防火墙未运行"
echo -e "${GREEN}✓ 防火墙配置完成${NC}"
echo ""

# 7. 启动所有服务
echo -e "${YELLOW}步骤 7/7: 启动所有服务...${NC}"
cd /root/oil

# 启动 Nginx
systemctl start nginx
systemctl enable nginx
echo -e "${GREEN}✓ Nginx 已启动${NC}"

# 重新构建并启动 Docker 服务
docker-compose up -d --build
echo -e "${GREEN}✓ Docker 服务已启动${NC}"
echo ""

# 8. 显示部署结果
echo "=========================================="
echo -e "${GREEN}✓ HTTPS 部署完成！${NC}"
echo "=========================================="
echo ""
echo "访问地址："
echo -e "  HTTPS: ${GREEN}https://$(hostname -I | awk '{print $1}')${NC}"
echo ""
echo "注意事项："
echo "  1. 首次访问会提示证书不安全，点击"继续访问"即可"
echo "  2. 手机访问时需要在浏览器中信任证书"
echo "  3. 阿里云用户需要在安全组中开放 443 端口"
echo ""
echo "服务状态检查："
docker-compose ps
echo ""
echo "Nginx 状态："
systemctl status nginx --no-pager | head -5
echo ""
echo -e "${GREEN}部署完成！现在可以使用 HTTPS 访问系统了。${NC}"

