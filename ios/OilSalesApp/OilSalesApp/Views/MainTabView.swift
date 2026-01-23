//
//  MainTabView.swift
//  OilSalesApp
//
//  主Tab导航视图
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProductListView()
                .tabItem {
                    Label("产品", systemImage: "cube.box.fill")
                        .font(.system(size: DesignSystem.bodyFont))
                }
                .tag(0)

            CustomerListView()
                .tabItem {
                    Label("客户", systemImage: "person.2.fill")
                        .font(.system(size: DesignSystem.bodyFont))
                }
                .tag(1)

            OrderListView()
                .tabItem {
                    Label("订单", systemImage: "doc.text.fill")
                        .font(.system(size: DesignSystem.bodyFont))
                }
                .tag(2)

            QRScannerView()
                .tabItem {
                    Label("扫码", systemImage: "qrcode.viewfinder")
                        .font(.system(size: DesignSystem.bodyFont))
                }
                .tag(3)

            MonthlyBillListView()
                .tabItem {
                    Label("月结", systemImage: "calendar")
                        .font(.system(size: DesignSystem.bodyFont))
                }
                .tag(4)
        }
        .accentColor(DesignSystem.primaryColor)
    }
}

#Preview {
    MainTabView()
}
