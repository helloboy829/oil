//
//  MonthlyBillListView.swift
//  OilSalesApp
//
//  月结账单列表视图
//

import SwiftUI

struct MonthlyBillListView: View {
    @StateObject private var viewModel = MonthlyBillViewModel()
    @StateObject private var customerViewModel = CustomerViewModel()
    @State private var selectedCustomer: Customer?
    @State private var showingCustomerPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 客户筛选
                VStack(spacing: DesignSystem.spacing) {
                    Button(action: { showingCustomerPicker = true }) {
                        HStack {
                            Text("筛选客户")
                                .font(.system(size: DesignSystem.bodyFont))
                                .foregroundColor(DesignSystem.primaryTextColor)

                            Spacer()

                            if let customer = selectedCustomer {
                                Text(customer.name)
                                    .font(.system(size: DesignSystem.bodyFont))
                                    .foregroundColor(DesignSystem.secondaryTextColor)
                            } else {
                                Text("全部客户")
                                    .font(.system(size: DesignSystem.bodyFont))
                                    .foregroundColor(DesignSystem.placeholderTextColor)
                            }

                            Image(systemName: "chevron.right")
                                .foregroundColor(DesignSystem.infoColor)
                        }
                        .padding()
                        .background(DesignSystem.backgroundColor)
                        .cornerRadius(DesignSystem.cornerRadius)
                    }

                    if selectedCustomer != nil {
                        Button(action: {
                            selectedCustomer = nil
                            Task {
                                await viewModel.loadBills()
                            }
                        }) {
                            Text("清除筛选")
                                .font(.system(size: DesignSystem.captionFont))
                                .foregroundColor(DesignSystem.dangerColor)
                        }
                    }
                }
                .padding()

                // 内容区域
                if viewModel.isLoading && viewModel.bills.isEmpty {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadBills()
                        }
                    }
                } else if viewModel.bills.isEmpty {
                    EmptyStateView(message: "暂无账单数据", icon: "calendar")
                } else {
                    billList
                }
            }
            .navigationTitle("月结账单")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCustomerPicker) {
                CustomerPickerView(viewModel: customerViewModel) { customer in
                    selectedCustomer = customer
                    Task {
                        await viewModel.loadBills(customerId: customer.id)
                    }
                }
            }
        }
        .task {
            await viewModel.loadBills()
            await customerViewModel.loadMonthlyCustomers()
        }
    }

    private var billList: some View {
        List {
            ForEach(viewModel.bills) { bill in
                NavigationLink(destination: MonthlyBillDetailView(bill: bill, viewModel: viewModel)) {
                    MonthlyBillRow(bill: bill)
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
                        await viewModel.loadMore(customerId: selectedCustomer?.id)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadBills(customerId: selectedCustomer?.id)
        }
    }
}

// MARK: - 账单行组件
struct MonthlyBillRow: View {
    let bill: MonthlyBill

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 客户名称和月份
            HStack {
                Text(bill.customerName ?? "未知客户")
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                    .foregroundColor(DesignSystem.primaryTextColor)

                Spacer()

                Text(bill.billMonth)
                    .font(.system(size: DesignSystem.captionFont))
                    .foregroundColor(DesignSystem.secondaryTextColor)
            }

            // 金额信息
            HStack(spacing: DesignSystem.spacing) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总金额")
                        .font(.system(size: DesignSystem.captionFont))
                        .foregroundColor(DesignSystem.secondaryTextColor)

                    Text(bill.totalAmount.currencyString)
                        .font(.system(size: DesignSystem.bodyFont, weight: .bold))
                        .foregroundColor(DesignSystem.primaryColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("未付金额")
                        .font(.system(size: DesignSystem.captionFont))
                        .foregroundColor(DesignSystem.secondaryTextColor)

                    Text(bill.unpaidAmount.currencyString)
                        .font(.system(size: DesignSystem.bodyFont, weight: .bold))
                        .foregroundColor(bill.unpaidAmount > 0 ? DesignSystem.dangerColor : DesignSystem.successColor)
                }
            }

            // 结算状态
            HStack {
                Spacer()

                TagView(
                    text: bill.settlementStatusEnum.displayName,
                    color: bill.settlementStatusEnum.color,
                    icon: bill.settlementStatusEnum.icon
                )
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MonthlyBillListView()
}
