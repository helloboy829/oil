//
//  Product.swift
//  OilSalesApp
//
//  产品数据模型
//

import Foundation
import SwiftUI

struct Product: Codable, Identifiable {
    let id: Int64
    let name: String
    let code: String
    let price: Double
    let stock: Int
    let unit: String
    let categoryId: Int64?
    let qrcodePath: String?
    let createTime: String?
    let updateTime: String?
    let deleted: Int?

    // 库存状态
    var stockStatus: StockStatus {
        if stock <= 0 {
            return .outOfStock
        } else if stock < 10 {
            return .low
        } else {
            return .sufficient
        }
    }

    // 二维码URL
    var qrcodeURL: URL? {
        guard let path = qrcodePath else { return nil }
        return URL(string: APIEndpoint.baseURL.replacingOccurrences(of: "/api", with: "") + path)
    }

    enum StockStatus {
        case sufficient
        case low
        case outOfStock

        var color: Color {
            switch self {
            case .sufficient:
                return .green
            case .low:
                return .yellow
            case .outOfStock:
                return .red
            }
        }

        var text: String {
            switch self {
            case .sufficient:
                return "充足"
            case .low:
                return "偏低"
            case .outOfStock:
                return "缺货"
            }
        }
    }
}

// 用于创建/更新产品的请求模型
struct ProductRequest: Codable {
    let id: Int64?
    let name: String
    let code: String
    let price: Double
    let stock: Int
    let unit: String
    let categoryId: Int64?
}
