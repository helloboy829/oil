# 日志管理方案

## 📋 概述

本系统实现了完整的日志管理方案，包括：
- 后端应用日志（Logback）
- Docker 容器日志
- 自动清理和备份
- 日志查看和搜索工具

---

## 📁 日志文件位置

### 1. 后端应用日志
存储在 Docker 卷中：`/var/lib/docker/volumes/oil_backend-logs/_data/`

文件列表：
- `oil-system.log` - 所有日志（当前）
- `oil-system-error.log` - 错误日志（当前）
- `oil-system-YYYY-MM-DD.*.log.gz` - 历史日志（压缩）
- `oil-system-error-YYYY-MM-DD.*.log.gz` - 历史错误日志（压缩）

### 2. Docker 容器日志
Docker 自动管理，位置：`/var/lib/docker/containers/`

每个容器限制：
- 单个日志文件最大 10MB
- 最多保留 3 个文件
- 总大小不超过 30MB

### 3. 备份日志
存储位置：`/root/oil-logs-backup/`

---

## 🔧 日志配置说明

### Logback 配置

**滚动策略：**
- 单个文件最大 100MB
- 按日期滚动（每天一个文件）
- 自动压缩为 .gz 格式
- 保留 30 天
- 总大小限制 3GB

**日志级别：**
- 生产环境：INFO
- SQL 日志：DEBUG（仅开发调试）
- 错误日志：单独文件记录

---

## 🛠️ 使用工具

### 1. 日志管理工具（logs-manager.sh）

**功能：**
- 查看所有容器日志
- 查看后端应用日志
- 查看错误日志
- 实时监控日志
- 清理旧日志
- 备份日志
- 查看日志统计
- 搜索日志内容

**使用方法：**
```bash
cd /root/oil/deploy
chmod +x logs-manager.sh
./logs-manager.sh
```

### 2. 自动清理脚本（auto-cleanup-logs.sh）

**功能：**
- 自动清理 30 天前的日志
- 清理 60 天前的备份
- 记录清理日志

**使用方法：**
```bash
cd /root/oil/deploy
chmod +x auto-cleanup-logs.sh

# 手动执行
./auto-cleanup-logs.sh

# 设置定时任务（每周日凌晨 2 点执行）
crontab -e
# 添加以下行：
0 2 * * 0 /root/oil/deploy/auto-cleanup-logs.sh
```

---

## 📊 常用命令

### 查看日志

```bash
# 查看后端实时日志
docker logs -f oil-backend

# 查看最后 100 行
docker logs --tail 100 oil-backend

# 查看特定时间段的日志
docker logs --since "2024-01-01T00:00:00" oil-backend

# 查看应用日志文件
docker exec oil-backend cat /app/logs/oil-system.log

# 查看错误日志
docker exec oil-backend cat /app/logs/oil-system-error.log
```

### 搜索日志

```bash
# 在日志中搜索关键词
docker logs oil-backend 2>&1 | grep "ERROR"

# 在应用日志文件中搜索
docker exec oil-backend grep "关键词" /app/logs/oil-system.log

# 搜索所有日志文件
docker exec oil-backend grep -r "关键词" /app/logs/
```

### 备份日志

```bash
# 手动备份
mkdir -p /root/oil-logs-backup
docker exec oil-backend tar czf /tmp/logs.tar.gz /app/logs
docker cp oil-backend:/tmp/logs.tar.gz /root/oil-logs-backup/logs-$(date +%Y%m%d).tar.gz
docker exec oil-backend rm /tmp/logs.tar.gz
```

### 清理日志

```bash
# 清理 Docker 容器日志
truncate -s 0 $(docker inspect --format='{{.LogPath}}' oil-backend)

# 清理应用日志（30 天前）
docker exec oil-backend find /app/logs -name "*.log.gz" -mtime +30 -delete
```

---

## 📈 日志监控建议

### 1. 定期检查
- 每周检查一次日志大小
- 每月检查一次错误日志
- 关注磁盘使用情况

### 2. 告警设置
建议监控以下指标：
- 错误日志数量突增
- 磁盘使用率超过 80%
- 日志文件大小异常

### 3. 日志分析
重点关注：
- ERROR 级别日志
- SQL 慢查询
- 异常堆栈信息
- 用户操作失败

---

## 🔍 故障排查

### 问题 1：日志文件过大

**原因：** 日志级别设置为 DEBUG 或日志量过大

**解决：**
```bash
# 修改日志级别为 INFO
# 编辑 backend/src/main/resources/logback-spring.xml
# 将 <root level="DEBUG"> 改为 <root level="INFO">

# 重启服务
docker-compose restart backend
```

### 问题 2：磁盘空间不足

**原因：** 日志文件未及时清理

**解决：**
```bash
# 立即清理旧日志
./deploy/auto-cleanup-logs.sh

# 检查磁盘使用
df -h

# 查看日志占用
du -sh /var/lib/docker/volumes/oil_backend-logs/
```

### 问题 3：无法查看日志

**原因：** 容器未运行或日志文件不存在

**解决：**
```bash
# 检查容器状态
docker ps -a

# 重启容器
docker-compose restart backend

# 检查日志目录
docker exec oil-backend ls -la /app/logs/
```

---

## 📝 最佳实践

1. **定期备份**
   - 每周自动备份一次
   - 重要操作前手动备份

2. **及时清理**
   - 设置自动清理定时任务
   - 保留 30 天内的日志

3. **监控告警**
   - 关注错误日志
   - 监控磁盘使用率

4. **日志分析**
   - 定期分析错误日志
   - 优化系统性能

5. **安全保护**
   - 日志文件权限控制
   - 敏感信息脱敏

---

## 📞 技术支持

如有问题，请检查：
1. 日志文件是否正常生成
2. Docker 容器是否正常运行
3. 磁盘空间是否充足
4. 日志配置是否正确
