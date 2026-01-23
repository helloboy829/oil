//
//  CustomerService.swift
//  OilSalesApp
//
//  客户服务层
//

import Foundation

class CustomerService {
    private let networkManager = NetworkManager.shared

    // 分页查询客户
    func getCustomers(page: Int = 1, size: Int = 10, name: String? = nil) async throws -> PageResponse<Customer> {
        var parameters: [String: String] = [
            "current": "\(page)",
            "size": "\(size)"
        ]

        if let name = name, !name.isEmpty {
            parameters["name"] = name
        }

        let response: APIResponse<PageResponse<Customer>> = try await networkManager.get(
            endpoint: APIEndpoint.Customer.page,
            parameters: parameters
        )

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    // 查询所有月结客户
    func getMonthlyCustomers() async throws -> [Customer] {
        let response: APIResponse<[Customer]> = try await networkManager.get(
            endpoint: APIEndpoint.Customer.monthly
        )

        guard let customers = response.data else {
            throw NetworkError.noData
        }

        return customers
    }

    // 创建客户
    func createCustomer(_ request: CustomerRequest) async throws {
        let _: APIResponse<EmptyResponse> = try await networkManager.post(
            endpoint: APIEndpoint.Customer.create,
            body: request
        )
    }

    // 更新客户
    func updateCustomer(_ request: CustomerRequest) async throws {
        let _: APIResponse<EmptyResponse> = try await networkManager.put(
            endpoint: APIEndpoint.Customer.update,
            body: request
        )
    }

    // 删除客户
    func deleteCustomer(id: Int64) async throws {
        let _: APIResponse<EmptyResponse> = try await networkManager.delete(
            endpoint: "\(APIEndpoint.Customer.delete)/\(id)"
        )
    }
}
