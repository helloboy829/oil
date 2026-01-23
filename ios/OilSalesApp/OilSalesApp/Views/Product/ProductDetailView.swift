//
//  ProductDetailView.swift
//  OilSalesApp
//
//  产品详情视图
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @ObservedObject var viewModel: ProductViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.largeSpacing) {
                // 二维码卡片
                if let qrcodeURL = product.qrcodeURL {
                    VStack(spacing: DesignSystem.spacing) {
                        Text("产品二维码")
                            .font(.system(size: DesignSystem.headlineFont, weight: .semibold))

                        AsyncImage(url: qrcodeURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 200, height: 200)
                        }
                    }
                    .padding()
                    .cardStyle()
                }

                // 基本信息卡片
                VStack(alignment: .leading, spacing: DesignSystem.spacing) {
                    Text("基本信息")
                        .font(.system(size: DesignSystem.headlineFont, weight: .semibold))

                    DetailRow(label: "产品名称", value: product.name)
                    DetailRow(label: "产品编码", value: product.code)
                    DetailRow(label: "单价", value: product.price.currencyString)
                    DetailRow(label: "单位", value: product.unit)

                    HStack {
                        Text("库存")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        HStack(spacing: 8) {
                            Text("\(product.stock)")
                                .font(.system(size: DesignSystem.bodyFont, weight: .semibold))

                            TagView(
                                text: product.stockStatus.text,
                                color: product.stockStatus.color
                            )
                        }
                    }

                    if let createTime = product.createTime {
                        DetailRow(label: "创建时间", value: createTime)
                    }
                }
                .padding()
                .cardStyle()

                // 操作按钮
                VStack(spacing: DesignSystem.spacing) {
                    LargeButton(
                        title: "编辑产品",
                        icon: "pencil",
                        color: DesignSystem.primaryColor
                    ) {
                        showingEditSheet = true
                    }

                    LargeButton(
                        title: "删除产品",
                        icon: "trash",
                        color: DesignSystem.dangerColor
                    ) {
                        showingDeleteAlert = true
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("产品详情")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            ProductFormView(viewModel: viewModel, product: product)
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                Task {
                    let success = await viewModel.deleteProduct(id: product.id)
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("确定要删除产品 \"\(product.name)\" 吗？")
        }
    }
}

// MARK: - 详情行组件
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: DesignSystem.bodyFont))
                .foregroundColor(DesignSystem.secondaryTextColor)

            Spacer()

            Text(value)
                .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                .foregroundColor(DesignSystem.primaryTextColor)
        }
    }
}
