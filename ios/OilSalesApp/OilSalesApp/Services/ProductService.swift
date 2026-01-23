//
//  ProductService.swift
//  OilSalesApp
//
//  产品服务层
//

import Foundation

class ProductService {
    private let networkManager = NetworkManager.shared

    // 分页查询产品
    func getProducts(page: Int = 1, size: Int = 10, name: String? = nil) async throws -> PageResponse<Product> {
        var parameters: [String: String] = [
            "current": "\(page)",
            "size": "\(size)"
        ]

        if let name = name, !name.isEmpty {
            parameters["name"] = name
        }

        let response: APIResponse<PageResponse<Product>> = try await networkManager.get(
            endpoint: APIEndpoint.Product.page,
            parameters: parameters
        )

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    // 根据编码查询产品
    func getProductByCode(_ code: String) async throws -> Product {
        let response: APIResponse<Product> = try await networkManager.get(
            endpoint: "\(APIEndpoint.Product.byCode)/\(code)"
        )

        guard let product = response.data else {
            throw NetworkError.noData
        }

        return product
    }

    // 创建产品
    func createProduct(_ request: ProductRequest) async throws {
        let _: APIResponse<EmptyResponse> = try await networkManager.post(
            endpoint: APIEndpoint.Product.create,
            body: request
        )
    }

    // 更新产品
    func updateProduct(_ request: ProductRequest) async throws {
        let _: APIResponse<EmptyResponse> = try await networkManager.put(
            endpoint: APIEndpoint.Product.update,
            body: request
        )
    }

    // 删除产品
    func deleteProduct(id: Int64) async throws {
        let _: APIResponse<EmptyResponse> = try await networkManager.delete(
            endpoint: "\(APIEndpoint.Product.delete)/\(id)"
        )
    }

    // 生成二维码
    func generateQRCode(id: Int64) async throws -> String {
        let response: APIResponse<String> = try await networkManager.post(
            endpoint: "\(APIEndpoint.Product.qrcode)/\(id)",
            body: EmptyResponse()
        )

        guard let qrcodePath = response.data else {
            throw NetworkError.noData
        }

        return qrcodePath
    }

    // 获取二维码路径
    func getQRCode(id: Int64) async throws -> String {
        let response: APIResponse<String> = try await networkManager.get(
            endpoint: "\(APIEndpoint.Product.qrcode)/\(id)"
        )

        guard let qrcodePath = response.data else {
            throw NetworkError.noData
        }

        return qrcodePath
    }
}
