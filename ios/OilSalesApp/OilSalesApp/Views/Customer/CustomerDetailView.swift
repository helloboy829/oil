//
//  CustomerDetailView.swift
//  OilSalesApp
//
//  客户详情视图
//

import SwiftUI

struct CustomerDetailView: View {
    let customer: Customer
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.largeSpacing) {
                // 基本信息卡片
                VStack(alignment: .leading, spacing: DesignSystem.spacing) {
                    Text("基本信息")
                        .font(.system(size: DesignSystem.headlineFont, weight: .semibold))

                    DetailRow(label: "客户名称", value: customer.name)

                    if let phone = customer.phone {
                        DetailRow(label: "联系电话", value: phone)
                    }

                    if let address = customer.address {
                        DetailRow(label: "地址", value: address)
                    }

                    HStack {
                        Text("客户类型")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        TagView(
                            text: customer.isMonthlyCustomer ? "月结客户" : "普通客户",
                            color: customer.isMonthlyCustomer ? DesignSystem.warningColor : DesignSystem.infoColor
                        )
                    }
                }
                .padding()
                .cardStyle()

                // 月结信息卡片（仅月结客户显示）
                if customer.isMonthlyCustomer {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing) {
                        Text("月结信息")
                            .font(.system(size: DesignSystem.headlineFont, weight: .semibold))

                        if let creditLimit = customer.creditLimit {
                            DetailRow(label: "信用额度", value: creditLimit.currencyString)
                        }

                        if let currentDebt = customer.currentDebt {
                            HStack {
                                Text("当前欠款")
                                    .font(.system(size: DesignSystem.bodyFont))
                                    .foregroundColor(DesignSystem.secondaryTextColor)

                                Spacer()

                                HStack(spacing: 8) {
                                    Text(currentDebt.currencyString)
                                        .font(.system(size: DesignSystem.bodyFont, weight: .bold))
                                        .foregroundColor(currentDebt > 0 ? DesignSystem.dangerColor : DesignSystem.successColor)

                                    if currentDebt > 0 {
                                        TagView(
                                            text: customer.debtStatus.text,
                                            color: customer.debtStatus.color
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                }

                // 操作按钮
                VStack(spacing: DesignSystem.spacing) {
                    LargeButton(
                        title: "编辑客户",
                        icon: "pencil",
                        color: DesignSystem.primaryColor
                    ) {
                        showingEditSheet = true
                    }

                    LargeButton(
                        title: "删除客户",
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
        .navigationTitle("客户详情")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            CustomerFormView(viewModel: viewModel, customer: customer)
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                Task {
                    let success = await viewModel.deleteCustomer(id: customer.id)
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("确定要删除客户 \"\(customer.name)\" 吗？")
        }
    }
}
