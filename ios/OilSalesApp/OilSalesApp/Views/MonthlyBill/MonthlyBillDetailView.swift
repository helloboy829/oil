//
//  MonthlyBillDetailView.swift
//  OilSalesApp
//
//  月结账单详情视图
//

import SwiftUI

struct MonthlyBillDetailView: View {
    let bill: MonthlyBill
    @ObservedObject var viewModel: MonthlyBillViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.largeSpacing) {
                // 账单信息卡片
                VStack(alignment: .leading, spacing: DesignSystem.spacing) {
                    Text("账单信息")
                        .font(.system(size: DesignSystem.headlineFont, weight: .semibold))

                    DetailRow(label: "客户名称", value: bill.customerName ?? "未知客户")
                    DetailRow(label: "账单月份", value: bill.billMonth)

                    HStack {
                        Text("结算状态")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        TagView(
                            text: bill.settlementStatusEnum.displayName,
                            color: bill.settlementStatusEnum.color,
                            icon: bill.settlementStatusEnum.icon
                        )
                    }

                    if let createTime = bill.createTime {
                        DetailRow(label: "创建时间", value: createTime)
                    }
                }
                .padding()
                .cardStyle()

                // 金额信息卡片
                VStack(alignment: .leading, spacing: DesignSystem.spacing) {
                    Text("金额信息")
                        .font(.system(size: DesignSystem.headlineFont, weight: .semibold))

                    HStack {
                        Text("总金额")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        Text(bill.totalAmount.currencyString)
                            .font(.system(size: DesignSystem.titleFont, weight: .bold))
                            .foregroundColor(DesignSystem.primaryColor)
                    }

                    Divider()

                    HStack {
                        Text("已付金额")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        Text(bill.paidAmount.currencyString)
                            .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                            .foregroundColor(DesignSystem.successColor)
                    }

                    HStack {
                        Text("未付金额")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        Text(bill.unpaidAmount.currencyString)
                            .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                            .foregroundColor(bill.unpaidAmount > 0 ? DesignSystem.dangerColor : DesignSystem.successColor)
                    }
                }
                .padding()
                .cardStyle()
            }
            .padding()
        }
        .navigationTitle("账单详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
