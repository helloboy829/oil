//
//  NetworkManager.swift
//  OilSalesApp
//
//  网络请求管理器
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    // 通用请求方法
    func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        parameters: [String: String]? = nil,
        body: Encodable? = nil
    ) async throws -> APIResponse<T> {
        // 构建URL
        var urlString = APIEndpoint.baseURL + endpoint

        // 添加查询参数
        if let parameters = parameters, !parameters.isEmpty {
            let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            var components = URLComponents(string: urlString)
            components?.queryItems = queryItems
            urlString = components?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        // 添加请求体
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }

        // 发送请求
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // 检查HTTP状态码
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkFailure
            }

            // 打印调试信息
            #if DEBUG
            print("📡 Request: \(method) \(urlString)")
            print("📥 Response Status: \(httpResponse.statusCode)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Response Data: \(jsonString)")
            }
            #endif

            // 处理不同的状态码
            switch httpResponse.statusCode {
            case 200...299:
                // 成功响应
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                do {
                    let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
                    return apiResponse
                } catch {
                    print("❌ Decoding Error: \(error)")
                    throw NetworkError.decodingError
                }

            case 401:
                throw NetworkError.unauthorized

            case 400...499:
                // 客户端错误
                if let errorResponse = try? JSONDecoder().decode(APIResponse<T>.self, from: data) {
                    throw NetworkError.serverError(errorResponse.message)
                }
                throw NetworkError.serverError("请求失败")

            case 500...599:
                // 服务器错误
                throw NetworkError.serverError("服务器错误")

            default:
                throw NetworkError.unknown
            }

        } catch let error as NetworkError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw NetworkError.networkFailure
        }
    }

    // GET 请求
    func get<T: Codable>(
        endpoint: String,
        parameters: [String: String]? = nil
    ) async throws -> APIResponse<T> {
        return try await request(endpoint: endpoint, method: "GET", parameters: parameters)
    }

    // POST 请求
    func post<T: Codable>(
        endpoint: String,
        body: Encodable
    ) async throws -> APIResponse<T> {
        return try await request(endpoint: endpoint, method: "POST", body: body)
    }

    // PUT 请求
    func put<T: Codable>(
        endpoint: String,
        body: Encodable
    ) async throws -> APIResponse<T> {
        return try await request(endpoint: endpoint, method: "PUT", body: body)
    }

    // DELETE 请求
    func delete<T: Codable>(
        endpoint: String
    ) async throws -> APIResponse<T> {
        return try await request(endpoint: endpoint, method: "DELETE")
    }
}
