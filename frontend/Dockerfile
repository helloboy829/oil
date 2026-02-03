# 多阶段构建 - 第一阶段：构建前端
FROM node:16-alpine AS build
WORKDIR /build

# 设置npm镜像源为淘宝镜像（加速国内访问）
RUN npm config set registry https://registry.npmmirror.com

# 复制package.json并安装依赖
COPY package*.json ./
RUN npm install

# 复制源代码并构建
COPY . .
RUN npm run build

# 第二阶段：使用nginx提供静态文件
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# 删除nginx默认页面
RUN rm -rf ./*

# 从构建阶段复制构建产物
COPY --from=build /build/dist .

# 创建SSL证书目录
RUN mkdir -p /etc/nginx/ssl

# 配置Alpine镜像源为国内镜像（加速访问）并生成自签名SSL证书
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=CN/ST=State/L=City/O=Organization/CN=localhost"

# 复制nginx HTTPS配置
COPY nginx-https.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80 443

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
