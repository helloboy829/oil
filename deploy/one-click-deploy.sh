#!/bin/bash

echo "=========================================="
echo "一键部署脚本"
echo "=========================================="

# 检查是否在正确的目录
if [ ! -f "docker-compose.yml" ]; then
    echo "错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose 未安装，正在安装..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 检查构建产物
if [ ! -f "backend/target/oil-system-1.0.0.jar" ]; then
    echo "错误: 找不到后端 JAR 文件"
    echo "请先在本地运行: mvn clean package"
    exit 1
fi

if [ ! -d "frontend/dist" ]; then
    echo "错误: 找不到前端构建产物"
    echo "请先在本地运行: npm run build"
    exit 1
fi

# 停止旧服务
echo "停止旧服务..."
docker-compose down 2>/dev/null || true

# 启动服务
echo "启动服务..."
docker-compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo ""
echo "=========================================="
echo "服务状态检查"
echo "=========================================="
docker-compose ps

echo ""
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo "访问地址: http://$(curl -s ifconfig.me)"
echo "H5扫码: http://$(curl -s ifconfig.me)/scan"
echo ""
echo "默认账号: admin"
echo "默认密码: admin123"
echo ""
echo "查看日志: docker-compose logs -f"
echo "=========================================="
