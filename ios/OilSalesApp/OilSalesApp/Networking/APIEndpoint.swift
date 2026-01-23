//
//  APIEndpoint.swift
//  OilSalesApp
//
//  API 端点定义
//

import Foundation

struct APIEndpoint {
    // 基础URL - 请根据实际部署修改
    static let baseURL = "http://localhost:8080/api"

    // 产品相关
    struct Product {
        static let page = "/product/page"
        static let list = "/product/list"
        static let byCode = "/product/code"
        static let create = "/product"
        static let update = "/product"
        static let delete = "/product"
        static let qrcode = "/product/qrcode"
    }

    // 客户相关
    struct Customer {
        static let page = "/customer/page"
        static let monthly = "/customer/monthly"
        static let create = "/customer"
        static let update = "/customer"
        static let delete = "/customer"
    }

    // 订单相关
    struct Order {
        static let page = "/order/page"
        static let create = "/order"
        static let detail = "/order"
    }

    // 月结账单相关
    struct MonthlyBill {
        static let page = "/monthly-bill/page"
        static let detail = "/monthly-bill"
    }
}
