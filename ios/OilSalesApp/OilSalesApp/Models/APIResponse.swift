//
//  APIResponse.swift
//  OilSalesApp
//
//  API 响应模型
//

import Foundation

// 通用API响应结构
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
}

// 空响应（用于删除、更新等操作）
struct EmptyResponse: Codable {}

// 分页响应
struct PageResponse<T: Codable>: Codable {
    let records: [T]
    let total: Int
    let size: Int
    let current: Int
    let pages: Int
}
