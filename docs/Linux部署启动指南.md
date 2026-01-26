# 油品系统 Linux 部署启动指南

## 目录
- [系统要求](#系统要求)
- [快速启动](#快速启动)
- [详细部署步骤](#详细部署步骤)
- [服务管理](#服务管理)
- [故障排查](#故障排查)

---

## 系统要求

### 硬件要求
- CPU：2核及以上
- 内存：4GB及以上
- 磁盘：20GB及以上可用空间

### 软件要求
- 操作系统：CentOS 7/8 或 Ubuntu 18.04+
- Docker：20.10+
- Docker Compose：1.29+
- Git：2.0+
- Nginx：1.20+（HTTPS 部署时需要）

---

## 快速启动

### 方式一：HTTP 部署（开发/测试环境）

```bash
# 1. 克隆代码
cd /
git clone https://github.com/helloboy829/oil.git
cd /oil

# 2. 启动服务
docker-compose up -d

# 3. 查看服务状态
docker-compose ps

# 4. 访问系统
# 浏览器访问：http://服务器IP
```

### 方式二：HTTPS 部署（生产环境推荐）

```bash
# 1. 克隆代码
cd /
git clone https://github.com/helloboy829/oil.git
cd /oil

# 2. 执行 HTTPS 部署脚本
bash deploy/setup-https.sh

# 3. 访问系统
# 浏览器访问：https://服务器IP
```

---

## 详细部署步骤

### 步骤 1：准备环境

#### 1.1 安装 Docker

```bash
# CentOS 系统
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker

# Ubuntu 系统
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
```

#### 1.2 安装 Docker Compose

```bash
# 下载 Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

#### 1.3 安装 Git

```bash
# CentOS
yum install -y git

# Ubuntu
apt-get install -y git
```

---

### 步骤 2：克隆项目代码

```bash
# 进入根目录
cd /

# 克隆代码
git clone https://github.com/helloboy829/oil.git

# 进入项目目录
cd /oil

# 查看项目结构
ls -la
```

**项目结构**：
```
/oil/
├── backend/          # 后端代码
├── frontend/         # 前端代码
├── deploy/           # 部署脚本和配置
├── docker-compose.yml
└── README.md
```

---

### 步骤 3：HTTP 部署（开发/测试）

#### 3.1 启动服务

```bash
cd /oil
docker-compose up -d
```

#### 3.2 查看服务状态

```bash
# 查看容器状态
docker-compose ps

# 查看容器日志
docker-compose logs -f
```

#### 3.3 等待服务就绪

```bash
# 等待 MySQL 初始化完成（约 30 秒）
docker logs oil-mysql

# 等待后端启动完成（约 1 分钟）
docker logs oil-backend

# 检查健康状态
docker-compose ps
```

#### 3.4 访问系统

- 浏览器访问：`http://服务器IP`
- 默认账号：admin
- 默认密码：123456

---

### 步骤 4：HTTPS 部署（生产环境）

#### 4.1 执行自动部署脚本

```bash
cd /oil
bash deploy/setup-https.sh
```

**脚本会自动完成以下操作**：
1. 停止当前运行的服务
2. 拉取最新代码
3. 安装 Nginx
4. 生成自签名 SSL 证书
5. 配置 Nginx
6. 配置防火墙
7. 启动所有服务

#### 4.2 手动部署步骤（可选）

如果自动脚本失败，可以手动执行：

```bash
# 1. 停止服务
cd /oil
docker-compose down

# 2. 安装 Nginx
yum install -y nginx  # CentOS
# 或
apt-get install -y nginx  # Ubuntu

# 3. 生成 SSL 证书
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/oil.key \
  -out /etc/nginx/ssl/oil.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Oil/CN=localhost"

# 4. 配置 Nginx
cp /oil/deploy/nginx-selfsigned.conf /etc/nginx/conf.d/oil.conf

# 5. 修改 Nginx 主配置
vi /etc/nginx/nginx.conf
# 注释掉默认的 server 块（监听 80 端口的部分）

# 6. 测试 Nginx 配置
nginx -t

# 7. 启动 Docker 服务
cd /oil
docker-compose up -d

# 8. 启动 Nginx
systemctl start nginx
systemctl enable nginx
```

#### 4.3 配置阿里云安全组

登录阿里云控制台，配置安全组规则：

| 规则方向 | 协议类型 | 端口范围 | 授权对象 | 描述 |
|---------|---------|---------|---------|------|
| 入方向 | TCP | 443/443 | 0.0.0.0/0 | HTTPS |
| 入方向 | TCP | 80/80 | 0.0.0.0/0 | HTTP（可选） |

#### 4.4 访问系统

- 浏览器访问：`https://服务器公网IP`
- 首次访问会提示"证书不安全"，点击"高级" → "继续访问"
- 默认账号：admin
- 默认密码：123456

---

## 服务管理

### Docker 服务管理

```bash
# 启动所有服务
cd /oil
docker-compose up -d

# 停止所有服务
docker-compose down

# 重启所有服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f

# 查看特定服务日志
docker logs oil-backend -f
docker logs oil-frontend -f
docker logs oil-mysql -f

# 重启单个服务
docker-compose restart backend
docker-compose restart frontend
docker-compose restart mysql
```

### Nginx 服务管理

```bash
# 启动 Nginx
systemctl start nginx

# 停止 Nginx
systemctl stop nginx

# 重启 Nginx
systemctl restart nginx

# 重新加载配置（不中断服务）
systemctl reload nginx

# 查看 Nginx 状态
systemctl status nginx

# 测试配置文件
nginx -t

# 设置开机自启
systemctl enable nginx
```

### 服务启动顺序

正确的启动顺序：
1. 启动 Docker 服务：`docker-compose up -d`
2. 等待容器启动完成（约 1-2 分钟）
3. 启动 Nginx（HTTPS 部署时）：`systemctl start nginx`

### 服务停止顺序

正确的停止顺序：
1. 停止 Nginx（如果使用）：`systemctl stop nginx`
2. 停止 Docker 服务：`docker-compose down`

---

## 故障排查

### 问题 1：容器无法启动

**检查步骤**：
```bash
# 查看容器状态
docker-compose ps

# 查看容器日志
docker-compose logs

# 查看特定容器日志
docker logs oil-backend
docker logs oil-mysql
```

**常见原因**：
- 端口被占用
- 磁盘空间不足
- 内存不足
- Docker 服务未启动

---

### 问题 2：MySQL 初始化失败

**检查步骤**：
```bash
# 查看 MySQL 日志
docker logs oil-mysql

# 检查数据卷
docker volume ls
docker volume inspect oil_mysql-data
```

**解决方案**：
```bash
# 删除数据卷重新初始化
docker-compose down -v
docker-compose up -d
```

---

### 问题 3：后端无法连接数据库

**检查步骤**：
```bash
# 查看后端日志
docker logs oil-backend

# 检查网络连接
docker exec oil-backend ping mysql
```

**常见原因**：
- MySQL 未完全启动
- 数据库密码错误
- 网络配置问题

---

### 问题 4：Nginx 启动失败

**检查步骤**：
```bash
# 查看 Nginx 错误日志
journalctl -xe -u nginx
cat /var/log/nginx/error.log

# 测试配置文件
nginx -t

# 检查端口占用
netstat -tlnp | grep :80
netstat -tlnp | grep :443
```

**常见原因**：
- 端口 80 或 443 被占用
- 配置文件语法错误
- SSL 证书文件不存在

**解决方案**：
```bash
# 检查并停止占用端口的进程
lsof -i :80
lsof -i :443

# 重新生成 SSL 证书
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/oil.key \
  -out /etc/nginx/ssl/oil.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Oil/CN=localhost"
```

---

### 问题 5：无法访问系统

**检查步骤**：
```bash
# 检查防火墙状态
systemctl status firewalld

# 检查防火墙规则
firewall-cmd --list-all

# 检查端口监听
netstat -tlnp | grep :80
netstat -tlnp | grep :443
```

**解决方案**：
```bash
# 开放端口
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# 或临时关闭防火墙测试
systemctl stop firewalld
```

---

### 问题 6：二维码生成失败

**检查步骤**：
```bash
# 检查二维码目录权限
docker exec oil-backend ls -la /app/qrcodes/

# 查看后端日志
docker logs oil-backend | grep -i qrcode
```

**解决方案**：
```bash
# 确保目录存在且有写权限
docker exec oil-backend mkdir -p /app/qrcodes
docker exec oil-backend chmod 755 /app/qrcodes
```

---

## 常用命令速查

### 系统信息
```bash
# 查看服务器 IP
hostname -I

# 查看磁盘使用
df -h

# 查看内存使用
free -h

# 查看 CPU 使用
top
```

### Docker 命令
```bash
# 查看所有容器
docker ps -a

# 查看镜像
docker images

# 查看数据卷
docker volume ls

# 清理未使用的资源
docker system prune -a
```

### 日志查看
```bash
# 实时查看日志
docker logs -f oil-backend

# 查看最后 100 行日志
docker logs --tail 100 oil-backend

# 查看指定时间的日志
docker logs --since 10m oil-backend
```

---

**文档版本**：1.0
**最后更新**：2026-01-26
**维护人员**：Claude Code Assistant
