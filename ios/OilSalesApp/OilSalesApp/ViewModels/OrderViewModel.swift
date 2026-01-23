//
//  OrderViewModel.swift
//  OilSalesApp
//
//  订单视图模型
//

import Foundation
import SwiftUI

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false

    private let service = OrderService()
    private let pageSize = AppConfig.defaultPageSize

    // 加载订单列表
    func loadOrders(orderNo: String? = nil, page: Int = 1) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.getOrders(page: page, size: pageSize, orderNo: orderNo)

            if page == 1 {
                orders = response.records
            } else {
                orders.append(contentsOf: response.records)
            }

            currentPage = response.current
            totalPages = response.pages
            hasMorePages = currentPage < totalPages

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Load orders error: \(error)")
        }

        isLoading = false
    }

    // 加载更多
    func loadMore(orderNo: String? = nil) async {
        guard !isLoading && hasMorePages else { return }
        await loadOrders(orderNo: orderNo, page: currentPage + 1)
    }

    // 创建订单
    func createOrder(
        customerId: Int64?,
        customerName: String?,
        paymentType: Order.PaymentType,
        items: [CartItem]
    ) async -> Order? {
        isLoading = true
        errorMessage = nil

        let orderItems = items.map { item in
            OrderItemRequest(
                productId: item.product.id,
                quantity: item.quantity,
                price: item.product.price
            )
        }

        let request = CreateOrderRequest(
            customerId: customerId,
            customerName: customerName,
            paymentType: paymentType.rawValue,
            items: orderItems
        )

        do {
            let order = try await service.createOrder(request)
            await loadOrders()  // 重新加载列表
            isLoading = false
            return order
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    // 查询订单详情
    func getOrderDetail(id: Int64) async -> Order? {
        do {
            let order = try await service.getOrderDetail(id: id)
            return order
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

// MARK: - 购物车项
struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int

    var subtotal: Double {
        return product.price * Double(quantity)
    }
}
