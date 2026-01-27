#!/bin/bash
# 443端口冲突解决脚本

echo "=== 检查443端口占用情况 ==="
netstat -tlnp | grep :443 || ss -tlnp | grep :443

echo ""
echo "=== 解决方案 ==="
echo "1. 如果是nginx占用，执行: systemctl stop nginx"
echo "2. 如果是apache占用，执行: systemctl stop apache2 或 systemctl stop httpd"
echo "3. 如果无法停止，可以使用8443端口（需要修改配置）"
echo ""

read -p "是否停止占用443端口的服务？(y/n): " choice

if [ "$choice" = "y" ]; then
    # 尝试停止常见的web服务
    systemctl stop nginx 2>/dev/null && echo "nginx已停止"
    systemctl stop apache2 2>/dev/null && echo "apache2已停止"
    systemctl stop httpd 2>/dev/null && echo "httpd已停止"

    echo ""
    echo "现在可以重新启动容器："
    echo "docker-compose up -d"
else
    echo ""
    echo "请手动停止占用443端口的服务，或者使用8443端口"
fi
