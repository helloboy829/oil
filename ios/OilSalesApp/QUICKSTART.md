# iOS 项目快速开始指南

## 📋 项目文件清单

### ✅ 已创建的文件（共 40+ 个文件）

#### 1. 网络层 (Networking/)
- [x] NetworkManager.swift - 网络请求管理器
- [x] APIEndpoint.swift - API 端点定义
- [x] NetworkError.swift - 错误定义

#### 2. 数据模型 (Models/)
- [x] APIResponse.swift - API 响应模型
- [x] Product.swift - 产品模型
- [x] Customer.swift - 客户模型
- [x] Order.swift - 订单模型
- [x] MonthlyBill.swift - 月结账单模型

#### 3. 服务层 (Services/)
- [x] ProductService.swift - 产品服务
- [x] CustomerService.swift - 客户服务
- [x] OrderService.swift - 订单服务
- [x] MonthlyBillService.swift - 月结账单服务

#### 4. 视图模型 (ViewModels/)
- [x] ProductViewModel.swift - 产品视图模型
- [x] CustomerViewModel.swift - 客户视图模型
- [x] OrderViewModel.swift - 订单视图模型
- [x] ScanViewModel.swift - 扫码视图模型
- [x] MonthlyBillViewModel.swift - 月结账单视图模型

#### 5. 工具类 (Utils/)
- [x] Constants.swift - 常量和设计系统
- [x] Extensions.swift - 扩展方法

#### 6. 视图组件 (Views/)
- [x] MainTabView.swift - 主 Tab 导航
- [x] Components/CommonViews.swift - 通用组件

**产品模块 (Views/Product/)**
- [x] ProductListView.swift - 产品列表
- [x] ProductDetailView.swift - 产品详情
- [x] ProductFormView.swift - 产品表单

**客户模块 (Views/Customer/)**
- [x] CustomerListView.swift - 客户列表
- [x] CustomerDetailView.swift - 客户详情
- [x] CustomerFormView.swift - 客户表单

**订单模块 (Views/Order/)**
- [x] OrderListView.swift - 订单列表
- [x] OrderDetailView.swift - 订单详情
- [x] CreateOrderView.swift - 创建订单

**扫码模块 (Views/Scan/)**
- [x] QRScannerView.swift - 二维码扫描
- [x] ShoppingCartView.swift - 购物车

**月结账单模块 (Views/MonthlyBill/)**
- [x] MonthlyBillListView.swift - 账单列表
- [x] MonthlyBillDetailView.swift - 账单详情

#### 7. App 入口 (App/)
- [x] OilSalesApp.swift - App 入口文件

#### 8. 配置文件 (Resources/)
- [x] Info.plist - 应用配置

#### 9. 文档
- [x] README.md - 项目说明文档
- [x] QUICKSTART.md - 快速开始指南（本文件）

---

## 🚀 快速开始

### 第一步：在 Xcode 中创建项目

1. 打开 Xcode
2. 选择 "Create a new Xcode project"
3. 选择 "iOS" -> "App"
4. 填写项目信息：
   - Product Name: `OilSalesApp`
   - Team: 选择你的开发团队
   - Organization Identifier: `com.yourcompany`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None`
5. 选择保存位置为 `d:\code\oil\ios\OilSalesApp`

### 第二步：导入已生成的代码文件

所有代码文件已经生成在 `d:\code\oil\ios\OilSalesApp\OilSalesApp\` 目录下。

在 Xcode 中：
1. 删除默认生成的 `ContentView.swift`
2. 右键点击项目导航器中的 `OilSalesApp` 文件夹
3. 选择 "Add Files to OilSalesApp..."
4. 选择以下文件夹并添加（勾选 "Create groups"）：
   - App/
   - Models/
   - ViewModels/
   - Views/
   - Services/
   - Networking/
   - Utils/
   - Resources/

### 第三步：配置项目设置

#### 1. 修改 API 地址

打开 `Networking/APIEndpoint.swift`，修改：
```swift
static let baseURL = "http://YOUR_SERVER_IP:8080/api"
```

将 `YOUR_SERVER_IP` 替换为：
- 本地测试：`localhost`（仅模拟器）或你的电脑 IP 地址（真机）
- 生产环境：你的服务器地址

#### 2. 配置 Info.plist

打开 `Info.plist`，确认以下权限已添加：
- Camera Usage Description（相机权限）
- Photo Library Usage Description（相册权限）

如果使用 HTTP（非 HTTPS），添加：
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

#### 3. 配置签名

1. 选择项目 -> Target -> Signing & Capabilities
2. 勾选 "Automatically manage signing"
3. 选择你的 Team
4. 确认 Bundle Identifier 唯一

### 第四步：运行项目

1. 选择目标设备（模拟器或真机）
2. 点击 Run 按钮（⌘R）
3. 等待编译完成

---

## 🔧 常见问题解决

### 问题 1：编译错误 "Cannot find type 'XXX' in scope"

**原因**：文件未正确添加到项目中

**解决**：
1. 检查文件是否在项目导航器中显示
2. 选中文件，查看右侧 Target Membership 是否勾选
3. 如果未勾选，勾选 OilSalesApp

### 问题 2：网络请求失败

**原因**：API 地址配置错误或后端未启动

**解决**：
1. 确认后端服务已启动（`http://localhost:8080`）
2. 检查 `APIEndpoint.swift` 中的 baseURL
3. 真机测试时，使用电脑的 IP 地址而非 localhost
4. 检查防火墙设置

### 问题 3：相机无法使用

**原因**：权限未配置或设备不支持

**解决**：
1. 确认 Info.plist 中已添加相机权限说明
2. 模拟器不支持相机，使用真机测试
3. 或使用"手动输入"功能代替扫码

### 问题 4：真机无法连接后端

**原因**：使用了 localhost

**解决**：
1. 查看电脑 IP 地址：
   - Windows: `ipconfig`
   - Mac: `ifconfig` 或系统偏好设置 -> 网络
2. 修改 `APIEndpoint.swift`：
   ```swift
   static let baseURL = "http://192.168.1.100:8080/api"
   ```
3. 确保手机和电脑在同一网络

---

## 📱 功能测试清单

### 产品管理
- [ ] 查看产品列表
- [ ] 搜索产品
- [ ] 查看产品详情
- [ ] 新增产品
- [ ] 编辑产品
- [ ] 删除产品
- [ ] 查看二维码

### 客户管理
- [ ] 查看客户列表
- [ ] 搜索客户
- [ ] 筛选月结客户
- [ ] 查看客户详情
- [ ] 新增客户
- [ ] 编辑客户
- [ ] 删除客户

### 订单管理
- [ ] 查看订单列表
- [ ] 搜索订单
- [ ] 查看订单详情
- [ ] 创建订单
- [ ] 选择客户
- [ ] 选择支付方式
- [ ] 添加商品到订单

### 扫码下单
- [ ] 扫描二维码
- [ ] 手动输入编码
- [ ] 添加商品到购物车
- [ ] 调整商品数量
- [ ] 删除购物车商品
- [ ] 选择客户
- [ ] 提交订单

### 月结账单
- [ ] 查看账单列表
- [ ] 筛选客户账单
- [ ] 查看账单详情

---

## 🎨 UI 预览

### 主界面
- 5 个 Tab：产品、客户、订单、扫码、月结
- 底部导航栏，图标清晰
- 老年人友好的大字体

### 列表页面
- 搜索栏
- 下拉刷新
- 上拉加载更多
- 空状态提示
- 加载指示器

### 详情页面
- 卡片式布局
- 信息分组清晰
- 操作按钮醒目
- 状态标签彩色

### 表单页面
- 大输入框
- 清晰的标签
- 验证提示
- 保存/取消按钮

---

## 📊 性能指标

### 目标性能
- 启动时间：< 2 秒
- 列表滚动：60 FPS
- 网络请求：< 1 秒
- 内存占用：< 100 MB

### 优化建议
- 使用图片缓存
- 实现列表虚拟化
- 减少不必要的重绘
- 优化网络请求

---

## 🔄 后续开发

### 优先级 P0（必须）
- [ ] 用户登录/认证
- [ ] 错误处理优化
- [ ] 数据验证增强

### 优先级 P1（重要）
- [ ] 本地数据缓存
- [ ] 离线模式支持
- [ ] 推送通知

### 优先级 P2（可选）
- [ ] iPad 适配
- [ ] 深色模式
- [ ] 数据统计图表
- [ ] 语音播报

---

## 📞 技术支持

如遇到问题：
1. 查看 README.md 详细文档
2. 检查控制台日志
3. 使用 Xcode 调试工具
4. 联系开发团队

---

## ✅ 完成检查

项目搭建完成后，确认：
- [x] 所有文件已添加到项目
- [x] API 地址已正确配置
- [x] 权限已正确配置
- [x] 项目可以成功编译
- [x] 可以连接到后端 API
- [x] 基本功能可以正常使用

恭喜！你已经成功搭建了 iOS 端项目！🎉
