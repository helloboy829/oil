# 油品销售管理系统 - iOS 端

这是油品销售管理系统的 iOS 原生应用，使用 Swift + SwiftUI 开发，专为老年用户设计。

## 📱 项目概述

- **开发语言**: Swift 5.5+
- **UI 框架**: SwiftUI
- **最低支持版本**: iOS 15.0+
- **架构模式**: MVVM (Model-View-ViewModel)
- **网络框架**: URLSession (async/await)

## 🎯 核心功能

### 1. 产品管理
- ✅ 产品列表查看（分页加载）
- ✅ 产品详情查看
- ✅ 产品新增/编辑/删除
- ✅ 产品搜索
- ✅ 二维码显示
- ✅ 库存状态指示（绿色/黄色/红色）

### 2. 客户管理
- ✅ 客户列表查看（分页加载）
- ✅ 客户详情查看
- ✅ 客户新增/编辑/删除
- ✅ 客户搜索
- ✅ 月结客户筛选
- ✅ 欠款状态提醒

### 3. 订单管理
- ✅ 订单列表查看（分页加载）
- ✅ 订单详情查看
- ✅ 创建订单
- ✅ 订单搜索
- ✅ 多种支付方式（现金、微信、支付宝、月结）
- ✅ 订单状态跟踪

### 4. 扫码下单
- ✅ 实时二维码扫描
- ✅ 手动输入产品编码
- ✅ 购物车管理
- ✅ 快速下单
- ✅ 客户选择
- ✅ 支付方式选择

### 5. 月结账单
- ✅ 账单列表查看（分页加载）
- ✅ 账单详情查看
- ✅ 客户筛选
- ✅ 结算状态显示

## 🏗️ 项目结构

```
OilSalesApp/
├── App/
│   └── OilSalesApp.swift              # App 入口
│
├── Models/                             # 数据模型
│   ├── APIResponse.swift              # API 响应模型
│   ├── Product.swift                  # 产品模型
│   ├── Customer.swift                 # 客户模型
│   ├── Order.swift                    # 订单模型
│   └── MonthlyBill.swift              # 月结账单模型
│
├── ViewModels/                         # 视图模型 (MVVM)
│   ├── ProductViewModel.swift
│   ├── CustomerViewModel.swift
│   ├── OrderViewModel.swift
│   ├── ScanViewModel.swift
│   └── MonthlyBillViewModel.swift
│
├── Views/                              # SwiftUI 视图
│   ├── MainTabView.swift              # 主 Tab 导航
│   ├── Components/                    # 通用组件
│   │   └── CommonViews.swift
│   ├── Product/                       # 产品模块
│   │   ├── ProductListView.swift
│   │   ├── ProductDetailView.swift
│   │   └── ProductFormView.swift
│   ├── Customer/                      # 客户模块
│   │   ├── CustomerListView.swift
│   │   ├── CustomerDetailView.swift
│   │   └── CustomerFormView.swift
│   ├── Order/                         # 订单模块
│   │   ├── OrderListView.swift
│   │   ├── OrderDetailView.swift
│   │   └── CreateOrderView.swift
│   ├── Scan/                          # 扫码模块
│   │   ├── QRScannerView.swift
│   │   └── ShoppingCartView.swift
│   └── MonthlyBill/                   # 月结账单模块
│       ├── MonthlyBillListView.swift
│       └── MonthlyBillDetailView.swift
│
├── Services/                           # 网络服务层
│   ├── ProductService.swift
│   ├── CustomerService.swift
│   ├── OrderService.swift
│   └── MonthlyBillService.swift
│
├── Networking/                         # 网络层
│   ├── NetworkManager.swift           # 网络请求管理器
│   ├── APIEndpoint.swift              # API 端点定义
│   └── NetworkError.swift             # 错误定义
│
├── Utils/                              # 工具类
│   ├── Constants.swift                # 常量和设计系统
│   └── Extensions.swift               # 扩展方法
│
└── Resources/                          # 资源文件
    └── Info.plist                     # 配置文件
```

## 🎨 设计特点

### 老年人友好设计
- **大字体**: 所有文字比标准大 20%
- **大按钮**: 最小 44x44pt，重要按钮 56pt 高
- **清晰对比**: 高对比度配色方案
- **简化导航**: Tab 导航，层级清晰
- **视觉反馈**: 明确的状态指示和颜色编码

### 设计系统
```swift
// 字体大小
titleFont: 28pt
bodyFont: 20pt
captionFont: 16pt

// 按钮尺寸
minButtonSize: 44pt
largeButtonHeight: 56pt

// 颜色系统
primaryColor: #409EFF (蓝色)
successColor: #67C23A (绿色)
warningColor: #E6A23C (橙色)
dangerColor: #F56C6C (红色)
```

## 🔧 配置说明

### 1. 修改 API 地址

在 `Networking/APIEndpoint.swift` 中修改：

```swift
struct APIEndpoint {
    // 修改为你的服务器地址
    static let baseURL = "http://your-server-ip:8080/api"
}
```

### 2. 相机权限配置

已在 `Info.plist` 中配置：
- `NSCameraUsageDescription`: 需要使用相机扫描产品二维码
- `NSPhotoLibraryUsageDescription`: 需要访问相册以选择二维码图片

### 3. 网络配置

如果使用 HTTP（非 HTTPS），需要在 `Info.plist` 中添加：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🚀 运行步骤

### 1. 环境要求
- macOS 13.0+
- Xcode 14.0+
- iOS 15.0+ 设备或模拟器

### 2. 打开项目
```bash
cd ios/OilSalesApp
open OilSalesApp.xcodeproj
```

### 3. 配置签名
1. 在 Xcode 中选择项目
2. 选择 Target -> Signing & Capabilities
3. 选择你的开发团队
4. 修改 Bundle Identifier（如需要）

### 4. 运行
1. 选择目标设备或模拟器
2. 点击 Run (⌘R)

## 📡 API 对接说明

### 后端 API 要求

所有 API 返回格式：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": { ... }
}
```

### 分页响应格式
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [...],
    "total": 100,
    "size": 10,
    "current": 1,
    "pages": 10
  }
}
```

### 已实现的 API 端点

**产品相关**
- `GET /product/page` - 分页查询产品
- `GET /product/code/{code}` - 根据编码查询
- `POST /product` - 创建产品
- `PUT /product` - 更新产品
- `DELETE /product/{id}` - 删除产品
- `GET /product/qrcode/{id}` - 获取二维码

**客户相关**
- `GET /customer/page` - 分页查询客户
- `GET /customer/monthly` - 查询月结客户
- `POST /customer` - 创建客户
- `PUT /customer` - 更新客户
- `DELETE /customer/{id}` - 删除客户

**订单相关**
- `GET /order/page` - 分页查询订单
- `POST /order` - 创建订单
- `GET /order/{id}` - 查询订单详情

**月结账单相关**
- `GET /monthly-bill/page` - 分页查询账单
- `GET /monthly-bill/{id}` - 查询账单详情

## 🔍 调试技巧

### 1. 网络请求调试

在 `NetworkManager.swift` 中已启用调试日志：
```swift
#if DEBUG
print("📡 Request: \(method) \(urlString)")
print("📥 Response Status: \(httpResponse.statusCode)")
print("📦 Response Data: \(jsonString)")
#endif
```

### 2. 模拟器测试扫码

由于模拟器无法使用相机，建议：
- 使用真机测试扫码功能
- 或使用"手动输入"功能测试

### 3. 网络连接问题

如果无法连接后端：
1. 确认后端服务已启动
2. 确认 API 地址配置正确
3. 如果使用 localhost，真机需要使用电脑的 IP 地址
4. 检查防火墙设置

## 📝 开发注意事项

### 1. 异步编程
所有网络请求使用 Swift 5.5+ 的 async/await：
```swift
Task {
    await viewModel.loadProducts()
}
```

### 2. 主线程更新
ViewModel 使用 `@MainActor` 确保 UI 更新在主线程：
```swift
@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
}
```

### 3. 内存管理
使用 `weak self` 避免循环引用：
```swift
DispatchQueue.main.async { [weak self] in
    self?.updateUI()
}
```

## 🎯 后续优化建议

### 功能增强
- [ ] 添加用户登录/认证
- [ ] 实现数据本地缓存（Core Data）
- [ ] 添加离线模式支持
- [ ] 实现推送通知
- [ ] 添加数据统计图表
- [ ] 支持 iPad 适配

### 性能优化
- [ ] 图片缓存优化
- [ ] 列表滚动性能优化
- [ ] 网络请求缓存
- [ ] 减少不必要的重绘

### 用户体验
- [ ] 添加骨架屏加载
- [ ] 优化错误提示
- [ ] 添加操作引导
- [ ] 支持深色模式
- [ ] 添加语音播报（辅助功能）

## 📄 许可证

本项目仅供学习和参考使用。

## 👥 联系方式

如有问题，请联系开发团队。
