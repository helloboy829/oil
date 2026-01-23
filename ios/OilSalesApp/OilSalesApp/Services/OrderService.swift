//
//  OrderService.swift
//  OilSalesApp
//
//  订单服务层
//

import Foundation

class OrderService {
    private let networkManager = NetworkManager.shared

    // 分页查询订单
    func getOrders(page: Int = 1, size: Int = 10, orderNo: String? = nil) async throws -> PageResponse<Order> {
        var parameters: [String: String] = [
            "current": "\(page)",
            "size": "\(size)"
        ]

        if let orderNo = orderNo, !orderNo.isEmpty {
            parameters["orderNo"] = orderNo
        }

        let response: APIResponse<PageResponse<Order>> = try await networkManager.get(
            endpoint: APIEndpoint.Order.page,
            parameters: parameters
        )

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    // 创建订单
    func createOrder(_ request: CreateOrderRequest) async throws -> Order {
        let response: APIResponse<Order> = try await networkManager.post(
            endpoint: APIEndpoint.Order.create,
            body: request
        )

        guard let order = response.data else {
            throw NetworkError.noData
        }

        return order
    }

    // 查询订单详情
    func getOrderDetail(id: Int64) async throws -> Order {
        let response: APIResponse<Order> = try await networkManager.get(
            endpoint: "\(APIEndpoint.Order.detail)/\(id)"
        )

        guard let order = response.data else {
            throw NetworkError.noData
        }

        return order
    }
}
