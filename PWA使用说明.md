# PWA 使用说明

## 什么是 PWA?

PWA (Progressive Web App) 是渐进式 Web 应用,让你的网站**像原生 APP 一样使用**。

### 主要特点

✅ **可安装到桌面** - 手机桌面有图标,点击直接打开
✅ **全屏体验** - 不显示浏览器地址栏
✅ **离线可用** - 没网络也能打开界面
✅ **快速加载** - 资源缓存,第二次打开更快
✅ **无需应用商店** - 不需要上架审核

---

## 一、生成应用图标

### 方法1: 使用图标生成工具(推荐)

1. 启动开发服务器:
   ```bash
   cd frontend
   npm run dev
   ```

2. 在浏览器打开:
   ```
   http://localhost:3000/generate-icons.html
   ```

3. 点击下载按钮,保存两个图标:
   - `icon-192.png` (192x192 像素)
   - `icon-512.png` (512x512 像素)

4. 将图标文件放到 `frontend/public/` 目录

### 方法2: 使用在线工具

访问: https://www.pwabuilder.com/imageGenerator

1. 上传你的 Logo 或设计图
2. 自动生成各种尺寸的图标
3. 下载 192x192 和 512x512 尺寸
4. 重命名为 `icon-192.png` 和 `icon-512.png`
5. 放到 `frontend/public/` 目录

---

## 二、测试 PWA 功能

### 本地测试

1. 构建生产版本:
   ```bash
   cd frontend
   npm run build
   ```

2. 预览构建结果:
   ```bash
   npm run preview
   ```

3. 在浏览器打开 `http://localhost:4173`

4. 打开浏览器开发者工具:
   - Chrome: F12 → Application → Service Workers
   - 查看 Service Worker 是否注册成功

### 检查清单

- [ ] manifest.json 文件存在
- [ ] 图标文件存在 (icon-192.png, icon-512.png)
- [ ] Service Worker 注册成功
- [ ] 浏览器显示"安装"提示

---

## 三、用户如何安装 PWA

### Android (Chrome)

**自动提示安装:**
1. 用 Chrome 打开网站
2. 浏览器自动弹出: "添加到主屏幕"
3. 点击"添加"
4. 桌面出现"油品销售"图标

**手动安装:**
1. 打开网站
2. 点击右上角 ⋮ (菜单)
3. 选择"添加到主屏幕"
4. 确认

### iOS (Safari)

1. 用 Safari 打开网站
2. 点击底部分享按钮 📤
3. 滚动找到"添加到主屏幕"
4. 点击"添加"
5. 桌面出现图标

### 电脑 (Chrome/Edge)

1. 打开网站
2. 地址栏右侧出现 ⊕ 图标
3. 点击"安装"
4. 应用出现在应用列表中

---

## 四、部署到服务器

### 重要提示

⚠️ **PWA 必须使用 HTTPS** (本地开发除外)
⚠️ Service Worker 只在 HTTPS 环境下工作

### 部署步骤

1. 构建前端:
   ```bash
   cd frontend
   npm run build
   ```

2. 上传到服务器:
   ```bash
   scp -r dist root@your-server-ip:/opt/oil/frontend/
   ```

3. 配置 Nginx (已包含在 docker-compose.yml 中)

4. 访问网站,测试安装功能

---

## 五、验证 PWA 配置

### 使用 Lighthouse 检查

1. 打开网站
2. F12 → Lighthouse 标签
3. 选择"Progressive Web App"
4. 点击"Generate report"
5. 查看评分和建议

### 常见问题

**问题1: 浏览器不显示安装提示**
- 检查是否使用 HTTPS
- 检查 manifest.json 是否正确加载
- 检查图标文件是否存在

**问题2: Service Worker 注册失败**
- 查看浏览器控制台错误信息
- 检查 sw.js 文件路径
- 确保在 HTTPS 环境

**问题3: 离线功能不工作**
- Service Worker 需要时间激活
- 刷新页面后再测试
- 检查缓存策略

---

## 六、PWA vs 原生 APP

| 特性 | PWA | 原生 APP |
|------|-----|----------|
| 安装 | 可选,无需应用商店 | 必须从应用商店下载 |
| 更新 | 自动更新 | 需要用户手动更新 |
| 开发成本 | 低(一套代码) | 高(iOS/Android 分别开发) |
| 离线使用 | 支持 | 支持 |
| 推送通知 | 部分支持 | 完全支持 |
| 性能 | 接近原生 | 最佳 |

---

## 七、后续优化建议

### 1. 添加推送通知(可选)

如果需要消息推送功能,可以集成 Web Push API。

### 2. 优化缓存策略

根据实际使用情况调整 Service Worker 缓存策略:
- 静态资源: 缓存优先
- API 数据: 网络优先,缓存备用

### 3. 添加更新提示

当有新版本时,提示用户刷新页面。

### 4. 性能监控

使用 Google Analytics 或其他工具监控 PWA 使用情况。

---

## 八、相关文件说明

```
frontend/
├── public/
│   ├── manifest.json          # PWA 配置文件
│   ├── sw.js                  # Service Worker
│   ├── icon-192.png          # 应用图标 192x192
│   ├── icon-512.png          # 应用图标 512x512
│   └── generate-icons.html   # 图标生成工具
├── index.html                # 已添加 PWA meta 标签
└── src/
    ├── main.js               # 已注册 Service Worker
    └── assets/styles/
        └── global.css        # 已添加移动端适配
```

---

## 九、技术支持

如有问题,请检查:
1. 浏览器控制台错误信息
2. Service Worker 状态
3. manifest.json 是否正确加载
4. 图标文件是否存在

更多信息: https://web.dev/progressive-web-apps/
