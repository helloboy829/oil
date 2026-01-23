//
//  MonthlyBillService.swift
//  OilSalesApp
//
//  月结账单服务层
//

import Foundation

class MonthlyBillService {
    private let networkManager = NetworkManager.shared

    // 分页查询月结账单
    func getMonthlyBills(page: Int = 1, size: Int = 10, customerId: Int64? = nil) async throws -> PageResponse<MonthlyBill> {
        var parameters: [String: String] = [
            "current": "\(page)",
            "size": "\(size)"
        ]

        if let customerId = customerId {
            parameters["customerId"] = "\(customerId)"
        }

        let response: APIResponse<PageResponse<MonthlyBill>> = try await networkManager.get(
            endpoint: APIEndpoint.MonthlyBill.page,
            parameters: parameters
        )

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    // 查询账单详情
    func getBillDetail(id: Int64) async throws -> MonthlyBill {
        let response: APIResponse<MonthlyBill> = try await networkManager.get(
            endpoint: "\(APIEndpoint.MonthlyBill.detail)/\(id)"
        )

        guard let bill = response.data else {
            throw NetworkError.noData
        }

        return bill
    }
}
