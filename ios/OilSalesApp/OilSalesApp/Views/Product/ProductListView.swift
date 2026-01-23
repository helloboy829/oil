//
//  ProductListView.swift
//  OilSalesApp
//
//  产品列表视图
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var searchText = ""
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(
                    text: $searchText,
                    placeholder: "搜索产品名称",
                    onSearch: {
                        Task {
                            await viewModel.loadProducts(name: searchText.isEmpty ? nil : searchText)
                        }
                    }
                )
                .padding()

                // 内容区域
                if viewModel.isLoading && viewModel.products.isEmpty {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                } else if viewModel.products.isEmpty {
                    EmptyStateView(message: "暂无产品数据", icon: "cube.box")
                } else {
                    productList
                }
            }
            .navigationTitle("产品管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ProductFormView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }

    // 产品列表
    private var productList: some View {
        List {
            ForEach(viewModel.products) { product in
                NavigationLink(destination: ProductDetailView(product: product, viewModel: viewModel)) {
                    ProductRow(product: product)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            // 加载更多
            if viewModel.hasMorePages {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .onAppear {
                    Task {
                        await viewModel.loadMore(name: searchText.isEmpty ? nil : searchText)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadProducts(name: searchText.isEmpty ? nil : searchText)
        }
    }
}

// MARK: - 产品行组件
struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: DesignSystem.spacing) {
            // 产品信息
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                    .foregroundColor(DesignSystem.primaryTextColor)

                Text("编码: \(product.code)")
                    .font(.system(size: DesignSystem.captionFont))
                    .foregroundColor(DesignSystem.secondaryTextColor)

                HStack(spacing: DesignSystem.spacing) {
                    Text(product.price.currencyString)
                        .font(.system(size: DesignSystem.bodyFont, weight: .bold))
                        .foregroundColor(DesignSystem.primaryColor)

                    Text("/ \(product.unit)")
                        .font(.system(size: DesignSystem.captionFont))
                        .foregroundColor(DesignSystem.secondaryTextColor)

                    Spacer()

                    // 库存状态
                    HStack(spacing: 4) {
                        Circle()
                            .fill(product.stockStatus.color)
                            .frame(width: 8, height: 8)

                        Text("库存: \(product.stock)")
                            .font(.system(size: DesignSystem.captionFont))
                            .foregroundColor(DesignSystem.regularTextColor)
                    }
                }
            }

            // 二维码图标
            Image(systemName: "qrcode")
                .font(.system(size: 32))
                .foregroundColor(DesignSystem.infoColor)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProductListView()
}
