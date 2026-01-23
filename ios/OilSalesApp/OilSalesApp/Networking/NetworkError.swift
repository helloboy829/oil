//
//  NetworkError.swift
//  OilSalesApp
//
//  网络错误定义
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case networkFailure
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL地址"
        case .noData:
            return "服务器未返回数据"
        case .decodingError:
            return "数据解析失败"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "未授权，请重新登录"
        case .networkFailure:
            return "网络连接失败，请检查网络"
        case .unknown:
            return "未知错误"
        }
    }
}
