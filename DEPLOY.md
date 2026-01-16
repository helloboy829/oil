# 机油销售管理系统 - Docker部署文档

## 一、服务器环境要求

### 1. 操作系统
- Linux (推荐 Ubuntu 20.04+ 或 CentOS 7+)
- 最低配置：2核CPU、4GB内存、20GB硬盘

### 2. 必须安装的软件

#### Docker
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh
sudo systemctl start docker
sudo systemctl enable docker

# CentOS
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
```

#### Docker Compose
```bash
# 下载最新版本
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

#### Git（可选，用于拉取代码）
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y git

# CentOS
sudo yum install -y git
```

---

## 二、部署步骤

### 1. 上传代码到服务器

**方法一：使用Git（推荐）**
```bash
# 在服务器上克隆代码
git clone <your-github-repo-url>
cd oil
```

**方法二：手动上传**
```bash
# 在本地打包
tar -czf oil.tar.gz oil/

# 使用scp上传到服务器
scp oil.tar.gz user@server-ip:/home/user/

# 在服务器上解压
tar -xzf oil.tar.gz
cd oil
```

### 2. 准备数据库初始化脚本

确保项目根目录有 `init.sql` 文件（数据库初始化脚本）。如果没有，需要导出现有数据库：

```bash
# 在本地导出数据库
mysqldump -u root -p oil_system > init.sql

# 上传到服务器的项目根目录
scp init.sql user@server-ip:/path/to/oil/
```

### 3. 修改配置（如需要）

编辑 `docker-compose.yml` 修改端口或密码：

```yaml
# MySQL密码
MYSQL_ROOT_PASSWORD: 123456  # 建议修改为强密码

# 端口映射（如果服务器端口被占用）
ports:
  - "8080:8080"  # 后端端口
  - "80:80"      # 前端端口
  - "3306:3306"  # MySQL端口
```

### 4. 启动服务

```bash
# 进入项目目录
cd oil

# 构建并启动所有服务（首次启动会自动构建镜像）
docker-compose up -d

# 查看启动日志
docker-compose logs -f

# 等待所有服务启动完成（约2-5分钟）
```

### 5. 验证部署

```bash
# 检查容器状态（所有容器应该是 Up 状态）
docker-compose ps

# 检查后端健康状态
curl http://localhost:8080/api/product/page?current=1&size=1

# 检查前端（在浏览器访问）
# http://服务器IP
```

---

## 三、常用管理命令

### 启动/停止服务
```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 重启所有服务
docker-compose restart

# 停止并删除所有容器、网络（保留数据卷）
docker-compose down

# 停止并删除所有容器、网络、数据卷（危险！会删除数据）
docker-compose down -v
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql
```

### 更新服务
```bash
# 拉取最新代码
git pull

# 重新构建并启动
docker-compose up -d --build

# 仅重新构建特定服务
docker-compose up -d --build backend
docker-compose up -d --build frontend
```

### 数据备份
```bash
# 备份MySQL数据
docker exec oil-mysql mysqldump -u root -p123456 oil_system > backup_$(date +%Y%m%d).sql

# 备份二维码文件
docker cp oil-backend:/app/qrcodes ./qrcodes_backup
```

---

## 四、防火墙配置

如果服务器启用了防火墙，需要开放端口：

### Ubuntu/Debian (UFW)
```bash
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 3306/tcp
sudo ufw reload
```

### CentOS (Firewalld)
```bash
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

---

## 五、故障排查

### 1. 容器无法启动
```bash
# 查看容器日志
docker-compose logs backend
docker-compose logs mysql

# 检查端口占用
netstat -tulpn | grep -E '80|8080|3306'
```

### 2. 数据库连接失败
```bash
# 检查MySQL是否启动
docker-compose ps mysql

# 进入MySQL容器检查
docker exec -it oil-mysql mysql -u root -p123456

# 检查数据库是否创建
SHOW DATABASES;
```

### 3. 前端无法访问后端
```bash
# 检查nginx配置
docker exec oil-frontend cat /etc/nginx/conf.d/default.conf

# 检查容器网络
docker network inspect oil_default
```

---

## 六、访问地址

部署成功后，可以通过以下地址访问：

- **前端页面**: http://服务器IP
- **后端API**: http://服务器IP:8080/api
- **MySQL数据库**: 服务器IP:3306

---

## 七、安全建议

1. **修改默认密码**
   - 修改MySQL root密码
   - 修改JWT密钥（backend/src/main/resources/application.yml）

2. **使用HTTPS**
   - 配置SSL证书
   - 使用Nginx反向代理

3. **限制数据库访问**
   - 不要将MySQL端口3306暴露到公网
   - 仅允许后端容器访问数据库

4. **定期备份**
   - 设置定时任务备份数据库
   - 备份二维码文件

---

## 八、性能优化建议

1. **调整JVM参数**（docker-compose.yml）
   ```yaml
   environment:
     JAVA_OPTS: "-Xms512m -Xmx1024m"
   ```

2. **启用Redis缓存**（可选）
   - 添加Redis容器
   - 配置Spring Cache

3. **使用CDN**
   - 将静态资源上传到CDN
   - 加速前端访问

---

## 联系方式

如有问题，请联系技术支持。
