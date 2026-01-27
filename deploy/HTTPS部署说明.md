# HTTPS部署说明

本文档说明如何为油品管理系统配置HTTPS，以便在手机上使用摄像头扫码功能。

## 方案：自签名SSL证书

使用自签名证书可以在没有域名的情况下启用HTTPS。

### 优点
- ✅ 不需要域名
- ✅ 可以使用IP地址访问
- ✅ 配置简单快速
- ✅ 完全免费

### 缺点
- ⚠️ 浏览器会提示"不安全"，需要手动信任证书（只需操作一次）

---

## 部署步骤

### 1. 在服务器上拉取最新代码

```bash
cd /path/to/oil
git pull
```

### 2. 生成SSL证书

```bash
# 进入部署目录
cd deploy

# 给脚本添加执行权限
chmod +x generate-ssl.sh

# 运行脚本生成证书
docker run --rm -v oil_ssl-certs:/etc/nginx/ssl alpine sh -c "
  apk add --no-cache openssl && \
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj '/C=CN/ST=Beijing/L=Beijing/O=Oil System/OU=IT/CN=oil-system' && \
  chmod 600 /etc/nginx/ssl/nginx-selfsigned.key && \
  chmod 644 /etc/nginx/ssl/nginx-selfsigned.crt && \
  ls -lh /etc/nginx/ssl/
"
```

### 3. 重新构建并启动服务

```bash
# 返回项目根目录
cd ..

# 停止现有服务
docker-compose down

# 重新构建并启动
docker-compose up -d --build
```

### 4. 验证HTTPS是否生效

```bash
# 检查容器状态
docker-compose ps

# 检查nginx日志
docker logs oil-frontend

# 测试HTTPS访问
curl -k https://localhost
```

---

## 手机端使用说明

### 首次访问时信任证书

1. 在手机浏览器中访问 `https://服务器IP`（例如：`https://192.168.1.100`）

2. 浏览器会显示"不安全"或"证书无效"的警告

3. **不同浏览器的操作方法：**

   **Chrome/Edge（安卓）：**
   - 点击"高级"
   - 点击"继续访问（不安全）"

   **Safari（iOS）：**
   - 点击"显示详细信息"
   - 点击"访问此网站"
   - 再次点击"访问此网站"确认

   **微信内置浏览器：**
   - 点击右上角"..."
   - 选择"在浏览器中打开"
   - 按照浏览器提示操作

4. 信任证书后，页面会正常加载

5. 现在可以使用扫码功能了！点击"开始扫码"，浏览器会请求摄像头权限，点击"允许"即可

---

## 常见问题

### Q1: 为什么浏览器提示"不安全"？

**A:** 因为使用的是自签名证书，不是由受信任的证书颁发机构（CA）签发的。这是正常的，不影响使用。

### Q2: 每次访问都需要信任证书吗？

**A:** 不需要。在同一台手机的同一个浏览器中，只需要信任一次。

### Q3: 如果想去掉"不安全"提示怎么办？

**A:** 需要：
1. 购买一个域名
2. 将域名解析到服务器IP
3. 使用Let's Encrypt申请免费的正式SSL证书

### Q4: 摄像头权限被拒绝怎么办？

**A:**
1. 检查浏览器设置中的权限管理
2. 确保使用的是HTTPS访问
3. 如果还是不行，可以使用"上传二维码图片"功能

### Q5: 局域网内其他设备无法访问怎么办？

**A:**
1. 检查服务器防火墙是否开放了80和443端口
2. 确保设备在同一局域网内
3. 使用服务器的局域网IP地址访问

---

## 端口说明

- **80端口（HTTP）**：自动重定向到HTTPS
- **443端口（HTTPS）**：主要访问端口
- **8080端口**：后端API服务（内部使用）

---

## 回滚到HTTP（如果需要）

如果遇到问题需要回滚到HTTP：

```bash
# 恢复nginx配置
git checkout deploy/nginx.conf

# 恢复docker-compose配置
git checkout docker-compose.yml

# 重新部署
docker-compose down
docker-compose up -d --build
```

---

## 技术支持

如有问题，请检查：
1. Docker容器日志：`docker logs oil-frontend`
2. Nginx配置：`docker exec oil-frontend cat /etc/nginx/conf.d/default.conf`
3. SSL证书：`docker exec oil-frontend ls -lh /etc/nginx/ssl/`
