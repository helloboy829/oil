//
//  LoadingView.swift
//  OilSalesApp
//
//  加载指示器组件
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: DesignSystem.spacing) {
            ProgressView()
                .scaleEffect(1.5)
            Text("加载中...")
                .font(.system(size: DesignSystem.bodyFont))
                .foregroundColor(DesignSystem.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.9))
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let message: String
    let icon: String

    var body: some View {
        VStack(spacing: DesignSystem.spacing) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.infoColor)

            Text(message)
                .font(.system(size: DesignSystem.bodyFont))
                .foregroundColor(DesignSystem.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 错误视图
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.largeSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.dangerColor)

            Text(message)
                .font(.system(size: DesignSystem.bodyFont))
                .foregroundColor(DesignSystem.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retryAction) {
                Text("重试")
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 120, height: DesignSystem.largeButtonHeight)
                    .background(DesignSystem.primaryColor)
                    .cornerRadius(DesignSystem.cornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 搜索栏
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.spacing) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DesignSystem.secondaryTextColor)

                TextField(placeholder, text: $text)
                    .font(.system(size: DesignSystem.bodyFont))
                    .submitLabel(.search)
                    .onSubmit(onSearch)

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        onSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.secondaryTextColor)
                    }
                }
            }
            .padding(DesignSystem.spacing)
            .background(DesignSystem.backgroundColor)
            .cornerRadius(DesignSystem.cornerRadius)

            Button(action: onSearch) {
                Text("搜索")
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 80, height: DesignSystem.minButtonSize)
                    .background(DesignSystem.primaryColor)
                    .cornerRadius(DesignSystem.cornerRadius)
            }
        }
    }
}

// MARK: - 标签视图
struct TagView: View {
    let text: String
    let color: Color
    let icon: String?

    init(text: String, color: Color, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12))
            }
            Text(text)
                .font(.system(size: DesignSystem.captionFont, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color)
        .cornerRadius(DesignSystem.smallCornerRadius)
    }
}

// MARK: - 大按钮（老年人友好）
struct LargeButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    init(title: String, icon: String? = nil, color: Color = DesignSystem.primaryColor, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.spacing) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                }
                Text(title)
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.largeButtonHeight)
            .background(color)
            .cornerRadius(DesignSystem.cornerRadius)
        }
    }
}
