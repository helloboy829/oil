//
//  OrderDetailView.swift
//  OilSalesApp
//
//  订单详情视图
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @ObservedObject var viewModel: OrderViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.largeSpacing) {
                // 订单信息卡片
                VStack(alignment: .leading, spacing: DesignSystem.spacing) {
                    Text("订单信息")
                        .font(.system(size: DesignSystem.headlineFont, weight: .semibold))

                    DetailRow(label: "订单号", value: order.orderNo ?? "N/A")

                    if let customerName = order.customerName {
                        DetailRow(label: "客户", value: customerName)
                    }

                    HStack {
                        Text("订单状态")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        TagView(
                            text: order.orderStatusEnum.displayName,
                            color: order.orderStatusEnum.color
                        )
                    }

                    HStack {
                        Text("支付方式")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        TagView(
                            text: order.paymentTypeEnum.displayName,
                            color: order.paymentTypeEnum.color,
                            icon: order.paymentTypeEnum.icon
                        )
                    }

                    HStack {
                        Text("支付状态")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        TagView(
                            text: order.paymentStatusEnum.displayName,
                            color: order.paymentStatusEnum.color
                        )
                    }

                    if let createTime = order.createTime {
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
                        Text("订单总额")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)

                        Spacer()

                        Text(order.totalAmount.currencyString)
                            .font(.system(size: DesignSystem.titleFont, weight: .bold))
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                }
                .padding()
                .cardStyle()
            }
            .padding()
        }
        .navigationTitle("订单详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
