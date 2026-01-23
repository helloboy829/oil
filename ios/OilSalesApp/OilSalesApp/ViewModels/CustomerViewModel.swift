//
//  CustomerViewModel.swift
//  OilSalesApp
//
//  客户视图模型
//

import Foundation
import SwiftUI

@MainActor
class CustomerViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var monthlyCustomers: [Customer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false

    private let service = CustomerService()
    private let pageSize = AppConfig.defaultPageSize

    // 加载客户列表
    func loadCustomers(name: String? = nil, page: Int = 1) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.getCustomers(page: page, size: pageSize, name: name)

            if page == 1 {
                customers = response.records
            } else {
                customers.append(contentsOf: response.records)
            }

            currentPage = response.current
            totalPages = response.pages
            hasMorePages = currentPage < totalPages

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Load customers error: \(error)")
        }

        isLoading = false
    }

    // 加载更多
    func loadMore(name: String? = nil) async {
        guard !isLoading && hasMorePages else { return }
        await loadCustomers(name: name, page: currentPage + 1)
    }

    // 加载月结客户
    func loadMonthlyCustomers() async {
        isLoading = true
        errorMessage = nil

        do {
            monthlyCustomers = try await service.getMonthlyCustomers()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Load monthly customers error: \(error)")
        }

        isLoading = false
    }

    // 创建客户
    func createCustomer(
        name: String,
        phone: String?,
        address: String?,
        isMonthly: Bool,
        creditLimit: Double?,
        currentDebt: Double?
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = CustomerRequest(
            id: nil,
            name: name,
            phone: phone,
            address: address,
            isMonthly: isMonthly ? 1 : 0,
            creditLimit: creditLimit,
            currentDebt: currentDebt
        )

        do {
            try await service.createCustomer(request)
            await loadCustomers()  // 重新加载列表
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // 更新客户
    func updateCustomer(
        id: Int64,
        name: String,
        phone: String?,
        address: String?,
        isMonthly: Bool,
        creditLimit: Double?,
        currentDebt: Double?
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = CustomerRequest(
            id: id,
            name: name,
            phone: phone,
            address: address,
            isMonthly: isMonthly ? 1 : 0,
            creditLimit: creditLimit,
            currentDebt: currentDebt
        )

        do {
            try await service.updateCustomer(request)
            await loadCustomers()  // 重新加载列表
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // 删除客户
    func deleteCustomer(id: Int64) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await service.deleteCustomer(id: id)
            await loadCustomers()  // 重新加载列表
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
