//
//  Customer.swift
//  OilSalesApp
//
//  客户数据模型
//

import Foundation
import SwiftUI

struct Customer: Codable, Identifiable {
    let id: Int64
    let name: String
    let phone: String?
    let address: String?
    let isMonthly: Int  // 0-否, 1-是
    let creditLimit: Double?
    let currentDebt: Double?
    let createTime: String?
    let updateTime: String?
    let deleted: Int?

    // 是否为月结客户
    var isMonthlyCustomer: Bool {
        return isMonthly == 1
    }

    // 欠款状态
    var debtStatus: DebtStatus {
        guard let debt = currentDebt, let limit = creditLimit else {
            return .normal
        }

        if debt <= 0 {
            return .normal
        } else if debt >= limit {
            return .exceeded
        } else if debt >= limit * 0.8 {
            return .warning
        } else {
            return .normal
        }
    }

    enum DebtStatus {
        case normal
        case warning
        case exceeded

        var color: Color {
            switch self {
            case .normal:
                return .green
            case .warning:
                return .yellow
            case .exceeded:
                return .red
            }
        }

        var text: String {
            switch self {
            case .normal:
                return "正常"
            case .warning:
                return "接近上限"
            case .exceeded:
                return "超出额度"
            }
        }
    }
}

// 用于创建/更新客户的请求模型
struct CustomerRequest: Codable {
    let id: Int64?
    let name: String
    let phone: String?
    let address: String?
    let isMonthly: Int
    let creditLimit: Double?
    let currentDebt: Double?
}
