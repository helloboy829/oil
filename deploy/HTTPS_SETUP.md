# HTTPS 配置指南

## 📋 为什么需要 HTTPS

现代浏览器（Chrome、Safari、Firefox等）出于安全考虑，**要求必须使用 HTTPS 才能访问摄像头**。

如果使用 HTTP 访问，会出现以下错误：
- ❌ "无法启动摄像头，请检查权限"
- ❌ "getUserMedia is not supported"
- ❌ 摄像头权限被拒绝

---

## 🔧 解决方案

### 方案一：使用 Nginx + Let's Encrypt（推荐，生产环境）

#### 1. 安装 Nginx

```bash
# 安装 Nginx
yum install -y nginx

# 启动 Nginx
systemctl start nginx
systemctl enable nginx
```

#### 2. 安装 Certbot（Let's Encrypt 客户端）

```bash
# 安装 EPEL 仓库
yum install -y epel-release

# 安装 Certbot
yum install -y certbot python3-certbot-nginx
```

#### 3. 获取 SSL 证书

```bash
# 替换 your-domain.com 为你的域名
certbot --nginx -d your-domain.com

# 按照提示输入邮箱，同意服务条款
# Certbot 会自动配置 Nginx 并获取证书
```

#### 4. 配置 Nginx

Nginx 配置文件已经为你准备好了，位于 `deploy/nginx.conf`

```bash
# 复制配置文件
cp /root/oil/deploy/nginx.conf /etc/nginx/conf.d/oil.conf

# 修改域名（替换 your-domain.com）
vi /etc/nginx/conf.d/oil.conf

# 测试配置
nginx -t

# 重启 Nginx
systemctl restart nginx
```

#### 5. 自动续期证书

Let's Encrypt 证书有效期 90 天，需要定期续期：

```bash
# 测试自动续期
certbot renew --dry-run

# 添加定时任务（每天凌晨 2 点检查并续期）
echo "0 2 * * * certbot renew --quiet && systemctl reload nginx" | crontab -
```

---

### 方案二：使用自签名证书（开发/测试环境）

如果没有域名或只是测试，可以使用自签名证书：

```bash
# 创建证书目录
mkdir -p /etc/nginx/ssl

# 生成自签名证书（有效期 365 天）
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/oil.key \
  -out /etc/nginx/ssl/oil.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Oil/CN=localhost"

# 使用 nginx-selfsigned.conf 配置
cp /root/oil/deploy/nginx-selfsigned.conf /etc/nginx/conf.d/oil.conf

# 重启 Nginx
systemctl restart nginx
```

**注意：** 自签名证书会在浏览器中显示"不安全"警告，需要手动信任。

---

## 📱 移动端访问

配置 HTTPS 后，使用以下地址访问：

- **有域名：** `https://your-domain.com`
- **自签名证书：** `https://服务器IP`（需要在手机浏览器中信任证书）

### 信任自签名证书（iOS）

1. 在 Safari 中访问 `https://服务器IP`
2. 点击"显示详细信息" → "访问此网站"
3. 输入密码确认

### 信任自签名证书（Android）

1. 在 Chrome 中访问 `https://服务器IP`
2. 点击"高级" → "继续访问"

---

## 🔍 验证 HTTPS 是否生效

```bash
# 检查 Nginx 状态
systemctl status nginx

# 检查端口监听
netstat -tlnp | grep nginx

# 测试 HTTPS 访问
curl -k https://localhost
```

浏览器访问：
- HTTP: `http://your-domain.com` → 自动跳转到 HTTPS
- HTTPS: `https://your-domain.com` → 显示绿色锁图标

---

## 🚨 常见问题

### 问题 1：防火墙未开放 443 端口

```bash
# 开放 443 端口
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# 或者直接开放端口
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
```

### 问题 2：阿里云安全组未开放 443 端口

1. 登录阿里云控制台
2. 进入 ECS 实例 → 安全组
3. 添加入方向规则：
   - 端口范围：443/443
   - 授权对象：0.0.0.0/0
   - 协议类型：TCP

### 问题 3：证书过期

```bash
# 手动续期
certbot renew

# 重启 Nginx
systemctl restart nginx
```

### 问题 4：摄像头仍然无法使用

1. 确认使用 HTTPS 访问（地址栏有锁图标）
2. 检查浏览器权限设置
3. 清除浏览器缓存和 Cookie
4. 尝试其他浏览器

---

## 📝 部署步骤总结

1. **安装 Nginx 和 Certbot**
2. **获取 SSL 证书**（Let's Encrypt 或自签名）
3. **配置 Nginx**（使用提供的配置文件）
4. **更新 Docker Compose**（前端端口改为 3000）
5. **重启服务**
6. **测试 HTTPS 访问**

---

## 🎯 下一步

配置完成后，请按照以下步骤部署：

```bash
cd /root/oil
git pull
docker-compose down
docker-compose up -d --build
systemctl restart nginx
```

然后使用 HTTPS 访问系统，摄像头功能应该可以正常使用了！
