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
   ssh root@<服务器IP>  # 实际IP不入库,见本地备忘,部署时填入
   cd /oil
   git pull origin main
   docker-compose up -d --build
   ```

3. **更新本地文档**（每次功能变更后）
   - 更新 `README.md` 的功能列表
   - 更新 `docs/修改记录.md` 的详细修改内容

### 快捷命令（可直接告诉我"帮我部署"）

当我说"帮我部署"或"deploy"时，按以下顺序执行：
1. 检查 git status，确认要提交的文件
2. 生成 commit message
3. push 到 GitHub
4. ssh 到服务器，执行 `cd /oil && git pull origin main && docker-compose down && docker-compose up -d --build`
5. 如有新 SQL 迁移文件，在服务器执行迁移
6. 更新 `docs/修改记录.md`

## 服务器信息

所有服务器连接信息（IP、SSH 用户、MySQL 密码、JWT 密钥、部署命令等）存放在 **`deploy/SERVER_INFO.md`**（仅本地，已 gitignore，不入 GitHub）。

部署前必须先读取该文件获取 IP 等信息。

### 如果 `deploy/SERVER_INFO.md` 不存在或丢失

**必须询问用户以下信息，并在用户提供后自动创建该文件：**

1. 服务器 IP（格式如 `120.79.211.158`）
2. SSH 登录用户（通常是 `root`）
3. MySQL root 密码
4. JWT 签名密钥（随机字符串，至少 32 字符）
5. 服务器上项目路径（通常是 `/oil`）
6. 是否有域名（可选）

询问示例："我注意到 `deploy/SERVER_INFO.md` 丢失了。为了能连接服务器和部署，请提供以下信息：
- 服务器 IP：
- SSH 用户（默认 root）：
- MySQL root 密码：
- 如果有 JWT 密钥请提供（没有的话我会生成一个随机密钥）："

收集到信息后，按以下模板创建 `deploy/SERVER_INFO.md`：
```markdown
# 服务器部署信息（仅本地保留，不入 Git）

## 连接信息
- **IP**: {用户提供的IP}
- **用户**: {用户提供的SSH用户}
- **SSH**: `ssh {用户}@{IP}`

## 项目信息
- **项目路径**: {用户提供的路径}
- **启动方式**: `docker-compose up -d --build`
- **停止方式**: `docker-compose down`

## 环境变量（服务器 .env）
MYSQL_ROOT_PASSWORD={用户提供的MySQL密码}
JWT_SECRET={用户提供的JWT密钥}

## 数据库
- **数据库名**: oil_system
- **用户**: root
- **密码**: {用户提供的MySQL密码}
```

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
| 商品管理 | views/Product.vue（含成本和利润率） |
| 客户管理 | views/Customer.vue |
| 订单管理 | views/Order.vue（含利润信息） |
| 月结账单 | views/MonthlyBill.vue |
| H5 扫码下单 | views/Scan.vue |
| 数据统计 | views/Statistics.vue（含利润分析） |
| 权限管理 | stores/auth.js + Home.vue |

## 重要文档

- **README.md** - 项目主文档，功能列表和快速开始
- **docs/修改记录.md** - 详细的修改记录和技术说明
- **PWA使用说明.md** - PWA 安装和使用指南
- **deploy/** - 部署相关文档（HTTPS、日志等）
