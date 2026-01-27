#!/bin/bash
# 更新前端代码并重新部署

echo "=== 开始更新前端 ==="

# 1. 拉取最新代码
echo "1. 拉取最新代码..."
git pull

# 2. 停止并删除旧的前端容器
echo "2. 停止前端容器..."
docker-compose stop frontend
docker-compose rm -f frontend

# 3. 重新构建并启动前端容器
echo "3. 重新构建前端容器..."
docker-compose build frontend

echo "4. 启动前端容器..."
docker-compose up -d frontend

# 5. 等待容器启动
echo "5. 等待容器启动..."
sleep 5

# 6. 检查容器状态
echo "6. 检查容器状态..."
docker-compose ps frontend

# 7. 查看容器日志
echo "7. 查看最近的日志..."
docker logs oil-frontend --tail 20

echo ""
echo "=== 前端更新完成！==="
echo "现在可以访问 https://服务器IP 查看更新后的页面"
