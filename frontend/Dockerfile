# 多阶段构建 - 第一阶段：构建前端
FROM node:16-alpine AS build
WORKDIR /build

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

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
