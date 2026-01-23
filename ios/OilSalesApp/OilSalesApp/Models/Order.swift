//
//  Order.swift
//  OilSalesApp
//
//  订单数据模型
//

import Foundation
import SwiftUI

struct Order: Codable, Identifiable {
    let id: Int64?
    let orderNo: String?
    let customerId: Int64?
    let customerName: String?
    let totalAmount: Double
    let paymentType: String  // CASH, WECHAT, ALIPAY, MONTHLY
    let paymentStatus: String  // PAID, UNPAID, PARTIAL
    let orderStatus: String  // PENDING, COMPLETED, CANCELLED
    let createTime: String?
    let updateTime: String?
    let deleted: Int?

    // 支付方式枚举
    var paymentTypeEnum: PaymentType {
        return PaymentType(rawValue: paymentType) ?? .cash
    }

    // 支付状态枚举
    var paymentStatusEnum: PaymentStatus {
        return PaymentStatus(rawValue: paymentStatus) ?? .unpaid
    }

    // 订单状态枚举
    var orderStatusEnum: OrderStatus {
        return OrderStatus(rawValue: orderStatus) ?? .pending
    }

    enum PaymentType: String, CaseIterable {
        case cash = "CASH"
        case wechat = "WECHAT"
        case alipay = "ALIPAY"
        case monthly = "MONTHLY"

        var displayName: String {
            switch self {
            case .cash: return "现金"
            case .wechat: return "微信"
            case .alipay: return "支付宝"
            case .monthly: return "月结"
            }
        }

        var color: Color {
            switch self {
            case .cash: return .green
            case .wechat: return .green
            case .alipay: return .blue
            case .monthly: return .orange
            }
        }

        var icon: String {
            switch self {
            case .cash: return "banknote"
            case .wechat: return "message.fill"
            case .alipay: return "creditcard.fill"
            case .monthly: return "calendar"
            }
        }
    }

    enum PaymentStatus: String {
        case paid = "PAID"
        case unpaid = "UNPAID"
        case partial = "PARTIAL"

        var displayName: String {
            switch self {
            case .paid: return "已支付"
            case .unpaid: return "未支付"
            case .partial: return "部分支付"
            }
        }

        var color: Color {
            switch self {
            case .paid: return .green
            case .unpaid: return .red
            case .partial: return .orange
            }
        }
    }

    enum OrderStatus: String {
        case pending = "PENDING"
        case completed = "COMPLETED"
        case cancelled = "CANCELLED"

        var displayName: String {
            switch self {
            case .pending: return "待处理"
            case .completed: return "已完成"
            case .cancelled: return "已取消"
            }
        }

        var color: Color {
            switch self {
            case .pending: return .orange
            case .completed: return .green
            case .cancelled: return .gray
            }
        }
    }
}

// 订单项
struct OrderItem: Codable, Identifiable {
    let id: Int64?
    let orderId: Int64?
    let productId: Int64
    let productName: String?
    let productCode: String?
    let quantity: Int
    let price: Double
    let subtotal: Double

    // 计算小计
    var calculatedSubtotal: Double {
        return Double(quantity) * price
    }
}

// 创建订单的请求模型
struct CreateOrderRequest: Codable {
    let customerId: Int64?
    let customerName: String?
    let paymentType: String
    let items: [OrderItemRequest]
}

struct OrderItemRequest: Codable {
    let productId: Int64
    let quantity: Int
    let price: Double
}

// 订单详情响应（包含订单项）
struct OrderDetail: Codable {
    let order: Order
    let items: [OrderItem]
}
