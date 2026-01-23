//
//  CustomerListView.swift
//  OilSalesApp
//
//  客户列表视图
//

import SwiftUI

struct CustomerListView: View {
    @StateObject private var viewModel = CustomerViewModel()
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var filterMonthlyOnly = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏和筛选
                VStack(spacing: DesignSystem.spacing) {
                    SearchBar(
                        text: $searchText,
                        placeholder: "搜索客户名称",
                        onSearch: {
                            Task {
                                await viewModel.loadCustomers(name: searchText.isEmpty ? nil : searchText)
                            }
                        }
                    )

                    // 月结客户筛选
                    Toggle("仅显示月结客户", isOn: $filterMonthlyOnly)
                        .font(.system(size: DesignSystem.bodyFont))
                        .padding(.horizontal)
                        .onChange(of: filterMonthlyOnly) { _ in
                            Task {
                                if filterMonthlyOnly {
                                    await viewModel.loadMonthlyCustomers()
                                } else {
                                    await viewModel.loadCustomers()
                                }
                            }
                        }
                }
                .padding()

                // 内容区域
                if viewModel.isLoading && viewModel.customers.isEmpty {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadCustomers()
                        }
                    }
                } else if displayCustomers.isEmpty {
                    EmptyStateView(message: "暂无客户数据", icon: "person.2")
                } else {
                    customerList
                }
            }
            .navigationTitle("客户管理")
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
                CustomerFormView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadCustomers()
        }
    }

    private var displayCustomers: [Customer] {
        filterMonthlyOnly ? viewModel.monthlyCustomers : viewModel.customers
    }

    private var customerList: some View {
        List {
            ForEach(displayCustomers) { customer in
                NavigationLink(destination: CustomerDetailView(customer: customer, viewModel: viewModel)) {
                    CustomerRow(customer: customer)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            if !filterMonthlyOnly && viewModel.hasMorePages {
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
            if filterMonthlyOnly {
                await viewModel.loadMonthlyCustomers()
            } else {
                await viewModel.loadCustomers(name: searchText.isEmpty ? nil : searchText)
            }
        }
    }
}

// MARK: - 客户行组件
struct CustomerRow: View {
    let customer: Customer

    var body: some View {
        HStack(spacing: DesignSystem.spacing) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(customer.name)
                        .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                        .foregroundColor(DesignSystem.primaryTextColor)

                    if customer.isMonthlyCustomer {
                        TagView(text: "月结", color: DesignSystem.warningColor)
                    }
                }

                if let phone = customer.phone {
                    Text(phone)
                        .font(.system(size: DesignSystem.captionFont))
                        .foregroundColor(DesignSystem.secondaryTextColor)
                }

                if customer.isMonthlyCustomer, let debt = customer.currentDebt, debt > 0 {
                    HStack(spacing: 8) {
                        Text("欠款: \(debt.currencyString)")
                            .font(.system(size: DesignSystem.captionFont, weight: .semibold))
                            .foregroundColor(DesignSystem.dangerColor)

                        TagView(
                            text: customer.debtStatus.text,
                            color: customer.debtStatus.color
                        )
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(DesignSystem.infoColor)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CustomerListView()
}
