//
//  ScanViewModel.swift
//  OilSalesApp
//
//  扫码视图模型
//

import Foundation
import SwiftUI
import AVFoundation

@MainActor
class ScanViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var scannedCode: String?
    @Published var isScanning = false
    @Published var errorMessage: String?
    @Published var selectedCustomer: Customer?

    let captureSession = AVCaptureSession()
    private let productService = ProductService()

    // 购物车总金额
    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }

    // 购物车商品总数
    var totalQuantity: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    // 开始扫描
    func startScanning() {
        guard !isScanning else { return }

        // 检查相机权限
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                }
            }
        default:
            errorMessage = "请在设置中允许访问相机"
        }
    }

    // 停止扫描
    func stopScanning() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
        isScanning = false
    }

    // 设置捕获会话
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            errorMessage = "无法访问相机"
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            errorMessage = "相机初始化失败"
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            errorMessage = "无法添加视频输入"
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(
                ScannerDelegate(viewModel: self),
                queue: DispatchQueue.main
            )
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            errorMessage = "无法添加元数据输出"
            return
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }

        isScanning = true
    }

    // 处理扫描结果
    func handleScannedCode(_ code: String) async {
        // 避免重复扫描
        guard scannedCode != code else { return }
        scannedCode = code

        // 根据编码查询产品
        do {
            let product = try await productService.getProductByCode(code)
            addToCart(product: product)
        } catch {
            errorMessage = "未找到该产品"
        }

        // 延迟后重置扫描状态
        try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1秒
        scannedCode = nil
    }

    // 添加到购物车
    func addToCart(product: Product, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            // 产品已存在，增加数量
            cartItems[index].quantity += quantity
        } else {
            // 新产品，添加到购物车
            let item = CartItem(product: product, quantity: quantity)
            cartItems.append(item)
        }
    }

    // 更新购物车商品数量
    func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                cartItems.remove(at: index)
            }
        }
    }

    // 从购物车移除商品
    func removeFromCart(item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }

    // 清空购物车
    func clearCart() {
        cartItems.removeAll()
        selectedCustomer = nil
    }

    // 选择客户
    func selectCustomer(_ customer: Customer) {
        selectedCustomer = customer
    }
}

// MARK: - 扫描器代理
class ScannerDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    weak var viewModel: ScanViewModel?

    init(viewModel: ScanViewModel) {
        self.viewModel = viewModel
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            // 震动反馈
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            // 处理扫描结果
            Task { @MainActor in
                await viewModel?.handleScannedCode(stringValue)
            }
        }
    }
}
