//
//  ProductViewModel.swift
//  OilSalesApp
//
//  产品视图模型
//

import Foundation
import SwiftUI

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false

    private let service = ProductService()
    private let pageSize = AppConfig.defaultPageSize

    // 加载产品列表
    func loadProducts(name: String? = nil, page: Int = 1) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.getProducts(page: page, size: pageSize, name: name)

            if page == 1 {
                products = response.records
            } else {
                products.append(contentsOf: response.records)
            }

            currentPage = response.current
            totalPages = response.pages
            hasMorePages = currentPage < totalPages

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Load products error: \(error)")
        }

        isLoading = false
    }

    // 加载更多
    func loadMore(name: String? = nil) async {
        guard !isLoading && hasMorePages else { return }
        await loadProducts(name: name, page: currentPage + 1)
    }

    // 根据编码查询产品
    func searchByCode(_ code: String) async -> Product? {
        do {
            let product = try await service.getProductByCode(code)
            return product
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // 创建产品
    func createProduct(name: String, code: String, price: Double, stock: Int, unit: String, categoryId: Int64?) async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = ProductRequest(
            id: nil,
            name: name,
            code: code,
            price: price,
            stock: stock,
            unit: unit,
            categoryId: categoryId
        )

        do {
            try await service.createProduct(request)
            await loadProducts()  // 重新加载列表
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // 更新产品
    func updateProduct(id: Int64, name: String, code: String, price: Double, stock: Int, unit: String, categoryId: Int64?) async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = ProductRequest(
            id: id,
            name: name,
            code: code,
            price: price,
            stock: stock,
            unit: unit,
            categoryId: categoryId
        )

        do {
            try await service.updateProduct(request)
            await loadProducts()  // 重新加载列表
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // 删除产品
    func deleteProduct(id: Int64) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await service.deleteProduct(id: id)
            await loadProducts()  // 重新加载列表
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // 生成二维码
    func generateQRCode(id: Int64) async -> String? {
        do {
            let qrcodePath = try await service.generateQRCode(id: id)
            return qrcodePath
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
