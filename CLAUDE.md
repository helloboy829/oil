# 油品销售管理系统 - 开发指南

## 项目简介

面向小型油品/零售场景的进销存管理系统。前端 Vue 3 + Element Plus，后端 Spring Boot + MyBatis-Plus + MySQL，支持 Docker 一键部署。

## 标准工作流

### 本地开发完成后的部署流程

1. **提交并推送代码到 GitHub**
   ```bash
   git add <files>
   git commit -m "描述"
   git push origin main
   ```

2. **SSH 登录服务器拉取并重启**
   ```bash
   ssh root@120.79.211.158
   cd /oil
   git pull origin main
   docker-compose up -d --build
   ```

3. **更新本地文档**（每次功能变更后）
   - 更新 `README.md` 的功能列表和更新日志
   - 更新其他相关文档（如有）

### 快捷命令（可直接告诉我"帮我部署"）

当我说"帮我部署"或"deploy"时，按以下顺序执行：
1. 检查 git status，确认要提交的文件
2. 生成 commit message
3. push 到 GitHub
4. ssh 到服务器执行 `cd /oil && git pull && docker-compose up -d --build`
5. 更新 README.md 的更新日志

## 服务器信息

- **IP**: 120.79.211.158
- **用户**: root
- **项目路径**: /oil
- **启动方式**: `docker-compose up -d --build`
- **日志查看**: `docker-compose logs -f`

## 技术栈

### 前端（frontend/）
- Vue 3 + Vite + Composition API
- Element Plus（深度定制，CSS 变量设计系统）
- Pinia 状态管理，Vue Router 4
- 图表：ECharts（统计页面）

### 后端（backend/）
- Spring Boot 2.7 + MyBatis-Plus + MySQL 8.0
- Java 11，ZXing 二维码

## 代码规范

- 新增页面参考 `frontend/src/views/Product.vue` 作为模板
- 使用 CSS 变量，不硬编码颜色（见 `frontend/src/assets/styles/global.css`）
- API 接口定义在 `frontend/src/api/`
- 后端控制器在 `backend/src/main/java/com/oil/system/controller/`

## 当前功能模块

| 模块 | 文件 |
|------|------|
| 商品管理 | views/Product.vue |
| 客户管理 | views/Customer.vue |
| 订单管理 | views/Order.vue |
| 月结账单 | views/MonthlyBill.vue |
| H5 扫码下单 | views/Scan.vue |
| 数据统计 | views/Statistics.vue（待开发） |
