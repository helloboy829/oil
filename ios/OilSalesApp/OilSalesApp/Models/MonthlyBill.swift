//
//  MonthlyBill.swift
//  OilSalesApp
//
//  月结账单数据模型
//

import Foundation
import SwiftUI

struct MonthlyBill: Codable, Identifiable {
    let id: Int64
    let customerId: Int64
    let customerName: String?
    let billMonth: String  // 格式: YYYY-MM
    let totalAmount: Double
    let paidAmount: Double
    let unpaidAmount: Double
    let settlementStatus: String  // SETTLED, UNSETTLED
    let createTime: String?
    let updateTime: String?
    let deleted: Int?

    // 结算状态枚举
    var settlementStatusEnum: SettlementStatus {
        return SettlementStatus(rawValue: settlementStatus) ?? .unsettled
    }

    enum SettlementStatus: String {
        case settled = "SETTLED"
        case unsettled = "UNSETTLED"

        var displayName: String {
            switch self {
            case .settled: return "已结算"
            case .unsettled: return "未结算"
            }
        }

        var color: Color {
            switch self {
            case .settled: return .green
            case .unsettled: return .orange
            }
        }

        var icon: String {
            switch self {
            case .settled: return "checkmark.circle.fill"
            case .unsettled: return "clock.fill"
            }
        }
    }
}

// 月结账单详情（包含订单列表）
struct MonthlyBillDetail: Codable {
    let bill: MonthlyBill
    let orders: [Order]
}
