//
//  OrderListView.swift
//  OilSalesApp
//
//  订单列表视图
//

import SwiftUI

struct OrderListView: View {
    @StateObject private var viewModel = OrderViewModel()
    @State private var searchText = ""
    @State private var showingCreateSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(
                    text: $searchText,
                    placeholder: "搜索订单号",
                    onSearch: {
                        Task {
                            await viewModel.loadOrders(orderNo: searchText.isEmpty ? nil : searchText)
                        }
                    }
                )
                .padding()

                // 内容区域
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadOrders()
                        }
                    }
                } else if viewModel.orders.isEmpty {
                    EmptyStateView(message: "暂无订单数据", icon: "doc.text")
                } else {
                    orderList
                }
            }
            .navigationTitle("订单管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateOrderView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadOrders()
        }
    }

    private var orderList: some View {
        List {
            ForEach(viewModel.orders) { order in
                NavigationLink(destination: OrderDetailView(order: order, viewModel: viewModel)) {
                    OrderRow(order: order)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            if viewModel.hasMorePages {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .onAppear {
                    Task {
                        await viewModel.loadMore(orderNo: searchText.isEmpty ? nil : searchText)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadOrders(orderNo: searchText.isEmpty ? nil : searchText)
        }
    }
}

// MARK: - 订单行组件
struct OrderRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 订单号和状态
            HStack {
                Text(order.orderNo ?? "N/A")
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                    .foregroundColor(DesignSystem.primaryTextColor)

                Spacer()

                TagView(
                    text: order.orderStatusEnum.displayName,
                    color: order.orderStatusEnum.color
                )
            }

            // 客户名称
            if let customerName = order.customerName {
                Text("客户: \(customerName)")
                    .font(.system(size: DesignSystem.captionFont))
                    .foregroundColor(DesignSystem.secondaryTextColor)
            }

            // 金额和支付信息
            HStack {
                Text(order.totalAmount.currencyString)
                    .font(.system(size: DesignSystem.bodyFont, weight: .bold))
                    .foregroundColor(DesignSystem.primaryColor)

                Spacer()

                HStack(spacing: 8) {
                    TagView(
                        text: order.paymentTypeEnum.displayName,
                        color: order.paymentTypeEnum.color,
                        icon: order.paymentTypeEnum.icon
                    )

                    TagView(
                        text: order.paymentStatusEnum.displayName,
                        color: order.paymentStatusEnum.color
                    )
                }
            }

            // 创建时间
            if let createTime = order.createTime {
                Text(createTime)
                    .font(.system(size: DesignSystem.captionFont))
                    .foregroundColor(DesignSystem.secondaryTextColor)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    OrderListView()
}
