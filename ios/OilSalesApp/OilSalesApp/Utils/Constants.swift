//
//  Constants.swift
//  OilSalesApp
//
//  常量定义
//

import Foundation
import SwiftUI

struct DesignSystem {
    // MARK: - 字体大小（老年人友好，比标准大20%）
    static let largeTitleFont: CGFloat = 34
    static let titleFont: CGFloat = 28
    static let headlineFont: CGFloat = 24
    static let bodyFont: CGFloat = 20
    static let calloutFont: CGFloat = 18
    static let captionFont: CGFloat = 16

    // MARK: - 按钮尺寸
    static let minButtonSize: CGFloat = 44  // 符合苹果人机界面指南
    static let largeButtonHeight: CGFloat = 56
    static let extraLargeButtonHeight: CGFloat = 64

    // MARK: - 间距
    static let smallSpacing: CGFloat = 8
    static let spacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32

    // MARK: - 圆角
    static let smallCornerRadius: CGFloat = 8
    static let cornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 16

    // MARK: - 阴影
    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: Double = 0.1

    // MARK: - 颜色（对应前端 CSS 变量）
    static let primaryColor = Color(hex: "#409EFF")
    static let successColor = Color(hex: "#67C23A")
    static let warningColor = Color(hex: "#E6A23C")
    static let dangerColor = Color(hex: "#F56C6C")
    static let infoColor = Color(hex: "#909399")

    // MARK: - 背景色
    static let backgroundColor = Color(hex: "#F5F7FA")
    static let cardBackgroundColor = Color.white

    // MARK: - 文字颜色
    static let primaryTextColor = Color(hex: "#303133")
    static let regularTextColor = Color(hex: "#606266")
    static let secondaryTextColor = Color(hex: "#909399")
    static let placeholderTextColor = Color(hex: "#C0C4CC")

    // MARK: - 边框
    static let borderColor = Color(hex: "#DCDFE6")
    static let borderWidth: CGFloat = 1
}

// MARK: - App 配置
struct AppConfig {
    // API 基础URL（请根据实际部署修改）
    static let apiBaseURL = "http://localhost:8080/api"

    // 分页配置
    static let defaultPageSize = 10

    // 缓存配置
    static let cacheExpirationTime: TimeInterval = 300  // 5分钟

    // 图片配置
    static let maxImageSize: CGFloat = 1024
    static let imageCompressionQuality: CGFloat = 0.8
}
