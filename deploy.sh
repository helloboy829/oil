#!/bin/bash

echo "=========================================="
echo "  机油销售管理系统 - 一键部署脚本"
echo "=========================================="
echo ""

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

echo "✅ Docker和Docker Compose已安装"
echo ""

# 停止旧容器
echo "🔄 停止旧容器..."
docker-compose down

# 构建并启动
echo "🚀 构建并启动服务..."
docker-compose up -d --build

echo ""
echo "⏳ 等待服务启动（约2-3分钟）..."
sleep 30

# 检查服务状态
echo ""
echo "📊 服务状态："
docker-compose ps

echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="
echo ""
echo "访问地址："
echo "  前端: http://localhost"
echo "  后端: http://localhost:8080"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"
echo "=========================================="
