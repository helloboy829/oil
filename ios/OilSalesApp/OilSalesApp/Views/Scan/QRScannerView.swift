//
//  QRScannerView.swift
//  OilSalesApp
//
//  二维码扫描视图
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @StateObject private var viewModel = ScanViewModel()
    @StateObject private var orderViewModel = OrderViewModel()
    @State private var showingCart = false
    @State private var showingManualInput = false
    @State private var manualCode = ""

    var body: some View {
        NavigationView {
            ZStack {
                // 相机预览
                CameraPreview(session: viewModel.captureSession)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    // 扫描框
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 250, height: 250)

                    Text("将二维码放入框内")
                        .font(.system(size: DesignSystem.bodyFont))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(DesignSystem.cornerRadius)
                        .padding(.top, 20)

                    Spacer()

                    // 底部操作栏
                    HStack(spacing: 20) {
                        // 手动输入按钮
                        Button(action: { showingManualInput = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "keyboard")
                                    .font(.system(size: 28))
                                Text("手动输入")
                                    .font(.system(size: DesignSystem.captionFont))
                            }
                            .foregroundColor(DesignSystem.primaryTextColor)
                            .frame(width: 100, height: 80)
                            .background(Color.white)
                            .cornerRadius(DesignSystem.cornerRadius)
                        }

                        // 购物车按钮
                        Button(action: { showingCart = true }) {
                            VStack(spacing: 8) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "cart.fill")
                                        .font(.system(size: 28))

                                    if viewModel.totalQuantity > 0 {
                                        Text("\(viewModel.totalQuantity)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(DesignSystem.dangerColor)
                                            .clipShape(Circle())
                                            .offset(x: 10, y: -10)
                                    }
                                }
                                Text("购物车")
                                    .font(.system(size: DesignSystem.captionFont))
                            }
                            .foregroundColor(DesignSystem.primaryTextColor)
                            .frame(width: 100, height: 80)
                            .background(Color.white)
                            .cornerRadius(DesignSystem.cornerRadius)
                        }

                        // 搜索按钮
                        Button(action: { showingManualInput = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 28))
                                Text("搜索")
                                    .font(.system(size: DesignSystem.captionFont))
                            }
                            .foregroundColor(DesignSystem.primaryTextColor)
                            .frame(width: 100, height: 80)
                            .background(Color.white)
                            .cornerRadius(DesignSystem.cornerRadius)
                        }
                    }
                    .padding(.bottom, 40)
                }

                // 错误提示
                if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(.white)
                            .padding()
                            .background(DesignSystem.dangerColor)
                            .cornerRadius(DesignSystem.cornerRadius)
                            .padding()
                        Spacer()
                    }
                }
            }
            .navigationTitle("扫码下单")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCart) {
                ShoppingCartView(
                    scanViewModel: viewModel,
                    orderViewModel: orderViewModel
                )
            }
            .sheet(isPresented: $showingManualInput) {
                ManualInputView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

// MARK: - 相机预览
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - 手动输入视图
struct ManualInputView: View {
    @ObservedObject var viewModel: ScanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""

    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.largeSpacing) {
                TextField("请输入产品编码", text: $code)
                    .font(.system(size: DesignSystem.bodyFont))
                    .padding()
                    .background(DesignSystem.backgroundColor)
                    .cornerRadius(DesignSystem.cornerRadius)
                    .padding()

                LargeButton(
                    title: "搜索",
                    icon: "magnifyingglass",
                    color: DesignSystem.primaryColor
                ) {
                    Task {
                        await viewModel.handleScannedCode(code)
                        dismiss()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("手动输入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QRScannerView()
}
