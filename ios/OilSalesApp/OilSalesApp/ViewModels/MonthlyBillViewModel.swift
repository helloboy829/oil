//
//  MonthlyBillViewModel.swift
//  OilSalesApp
//
//  月结账单视图模型
//

import Foundation
import SwiftUI

@MainActor
class MonthlyBillViewModel: ObservableObject {
    @Published var bills: [MonthlyBill] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false

    private let service = MonthlyBillService()
    private let pageSize = AppConfig.defaultPageSize

    // 加载账单列表
    func loadBills(customerId: Int64? = nil, page: Int = 1) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.getMonthlyBills(
                page: page,
                size: pageSize,
                customerId: customerId
            )

            if page == 1 {
                bills = response.records
            } else {
                bills.append(contentsOf: response.records)
            }

            currentPage = response.current
            totalPages = response.pages
            hasMorePages = currentPage < totalPages

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Load bills error: \(error)")
        }

        isLoading = false
    }

    // 加载更多
    func loadMore(customerId: Int64? = nil) async {
        guard !isLoading && hasMorePages else { return }
        await loadBills(customerId: customerId, page: currentPage + 1)
    }

    // 查询账单详情
    func getBillDetail(id: Int64) async -> MonthlyBill? {
        do {
            let bill = try await service.getBillDetail(id: id)
            return bill
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
