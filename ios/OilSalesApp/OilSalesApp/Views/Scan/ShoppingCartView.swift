//
//  ShoppingCartView.swift
//  OilSalesApp
//
//  购物车视图
//

import SwiftUI

struct ShoppingCartView: View {
    @ObservedObject var scanViewModel: ScanViewModel
    @ObservedObject var orderViewModel: OrderViewModel
    @StateObject private var customerViewModel = CustomerViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPaymentType: Order.PaymentType = .cash
    @State private var showingCustomerPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var orderSuccess = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if scanViewModel.cartItems.isEmpty {
                    EmptyStateView(message: "购物车是空的", icon: "cart")
                } else {
                    Form {
                        // 客户选择
                        Section(header: Text("客户信息").font(.system(size: DesignSystem.bodyFont))) {
                            Button(action: { showingCustomerPicker = true }) {
                                HStack {
                                    Text("选择客户")
                                        .font(.system(size: DesignSystem.bodyFont))
                                        .foregroundColor(DesignSystem.primaryTextColor)

                                    Spacer()

                                    if let customer = scanViewModel.selectedCustomer {
                                        Text(customer.name)
                                            .font(.system(size: DesignSystem.bodyFont))
                                            .foregroundColor(DesignSystem.secondaryTextColor)
                                    } else {
                                        Text("未选择")
                                            .font(.system(size: DesignSystem.bodyFont))
                                            .foregroundColor(DesignSystem.placeholderTextColor)
                                    }

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(DesignSystem.infoColor)
                                }
                            }
                        }

                        // 支付方式
                        Section(header: Text("支付方式").font(.system(size: DesignSystem.bodyFont))) {
                            Picker("支付方式", selection: $selectedPaymentType) {
                                ForEach(Order.PaymentType.allCases, id: \.self) { type in
                                    Text(type.displayName)
                                        .font(.system(size: DesignSystem.bodyFont))
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // 商品列表
                        Section(header: Text("商品列表").font(.system(size: DesignSystem.bodyFont))) {
                            ForEach(scanViewModel.cartItems) { item in
                                CartItemRow(item: item) { newQuantity in
                                    scanViewModel.updateQuantity(for: item, quantity: newQuantity)
                                } onRemove: {
                                    scanViewModel.removeFromCart(item: item)
                                }
                            }
                        }

                        // 总金额
                        Section {
                            HStack {
                                Text("订单总额")
                                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))

                                Spacer()

                                Text(scanViewModel.totalAmount.currencyString)
                                    .font(.system(size: DesignSystem.titleFont, weight: .bold))
                                    .foregroundColor(DesignSystem.primaryColor)
                            }
                        }
                    }

                    // 提交按钮
                    VStack(spacing: 0) {
                        Divider()

                        HStack(spacing: DesignSystem.spacing) {
                            Button(action: {
                                scanViewModel.clearCart()
                                dismiss()
                            }) {
                                Text("清空")
                                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                                    .foregroundColor(DesignSystem.dangerColor)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: DesignSystem.largeButtonHeight)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.cornerRadius)
                                            .stroke(DesignSystem.dangerColor, lineWidth: 2)
                                    )
                                    .cornerRadius(DesignSystem.cornerRadius)
                            }

                            Button(action: submitOrder) {
                                Text("提交订单")
                                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: DesignSystem.largeButtonHeight)
                                    .background(DesignSystem.primaryColor)
                                    .cornerRadius(DesignSystem.cornerRadius)
                            }
                            .disabled(orderViewModel.isLoading)
                        }
                        .padding()
                    }
                    .background(Color.white)
                }
            }
            .navigationTitle("购物车")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCustomerPicker) {
                CustomerPickerView(viewModel: customerViewModel) { customer in
                    scanViewModel.selectCustomer(customer)
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                if orderSuccess {
                    Button("确定") {
                        scanViewModel.clearCart()
                        dismiss()
                    }
                } else {
                    Button("确定", role: .cancel) {}
                }
            } message: {
                Text(alertMessage)
            }
        }
        .task {
            await customerViewModel.loadCustomers()
        }
    }

    private func submitOrder() {
        Task {
            let order = await orderViewModel.createOrder(
                customerId: scanViewModel.selectedCustomer?.id,
                customerName: scanViewModel.selectedCustomer?.name,
                paymentType: selectedPaymentType,
                items: scanViewModel.cartItems
            )

            if order != nil {
                alertMessage = "订单创建成功！"
                orderSuccess = true
                showingAlert = true
            } else if let error = orderViewModel.errorMessage {
                alertMessage = error
                orderSuccess = false
                showingAlert = true
            }
        }
    }
}
