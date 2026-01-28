# 数据持久化说明

## 📁 数据存储目录结构

```
data/
├── mysql/          # MySQL数据库文件
├── qrcodes/        # 商品二维码图片
├── logs/           # 后端日志文件
├── ssl/            # SSL证书文件
└── backups/        # 数据库备份文件
```

## ⚠️ 重要说明

1. **data目录不会提交到git仓库**
   - 已添加到 `.gitignore`
   - 包含所有持久化数据和敏感信息

2. **首次部署需要创建目录**
   ```bash
   mkdir -p data/mysql data/qrcodes data/logs data/ssl data/backups
   ```

3. **数据备份**
   - 使用 `deploy/backup.sh` 进行手动备份
   - 备份文件保存在 `data/backups/` 目录
   - 建议设置定时任务自动备份

4. **数据恢复**
   - 使用 `deploy/restore.sh` 恢复数据
   - 需要指定备份文件路径

## 🔄 迁移现有数据

如果你之前使用Docker volumes存储数据，需要迁移：

```bash
# 1. 停止服务
docker-compose down

# 2. 创建数据目录
mkdir -p data/mysql data/qrcodes data/logs data/backups

# 3. 从旧volume复制数据（如果存在）
docker run --rm -v oil_mysql-data:/from -v $(pwd)/data/mysql:/to alpine sh -c "cd /from && cp -av . /to"
docker run --rm -v oil_qrcode-data:/from -v $(pwd)/data/qrcodes:/to alpine sh -c "cd /from && cp -av . /to"
docker run --rm -v oil_backend-logs:/from -v $(pwd)/data/logs:/to alpine sh -c "cd /from && cp -av . /to"

# 4. 启动服务
docker-compose up -d --build

# 5. 删除旧volumes（可选）
docker volume rm oil_mysql-data oil_qrcode-data oil_backend-logs oil_ssl-certs
```

## 🛡️ 数据安全建议

1. **定期备份**
   - 每天自动备份数据库
   - 保留最近7天的备份

2. **异地备份**
   - 将 `data/backups/` 目录同步到其他服务器
   - 使用云存储服务（如阿里云OSS、腾讯云COS）

3. **权限控制**
   ```bash
   chmod 700 data/mysql
   chmod 755 data/qrcodes
   chmod 755 data/backups
   ```

4. **监控磁盘空间**
   ```bash
   df -h
   du -sh data/*
   ```
