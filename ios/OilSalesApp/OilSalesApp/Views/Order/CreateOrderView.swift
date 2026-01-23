//
//  CreateOrderView.swift
//  OilSalesApp
//
//  创建订单视图
//

import SwiftUI

struct CreateOrderView: View {
    @ObservedObject var viewModel: OrderViewModel
    @StateObject private var productViewModel = ProductViewModel()
    @StateObject private var customerViewModel = CustomerViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCustomer: Customer?
    @State private var selectedPaymentType: Order.PaymentType = .cash
    @State private var cartItems: [CartItem] = []
    @State private var showingProductPicker = false
    @State private var showingCustomerPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }

    var body: some View {
        NavigationView {
            Form {
                // 客户选择
                Section(header: Text("客户信息").font(.system(size: DesignSystem.bodyFont))) {
                    Button(action: { showingCustomerPicker = true }) {
                        HStack {
                            Text("选择客户")
                                .font(.system(size: DesignSystem.bodyFont))
                                .foregroundColor(DesignSystem.primaryTextColor)

                            Spacer()

                            if let customer = selectedCustomer {
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
                    if cartItems.isEmpty {
                        Text("暂无商品")
                            .font(.system(size: DesignSystem.bodyFont))
                            .foregroundColor(DesignSystem.secondaryTextColor)
                    } else {
                        ForEach(cartItems) { item in
                            CartItemRow(item: item) { newQuantity in
                                updateQuantity(for: item, quantity: newQuantity)
                            } onRemove: {
                                removeItem(item)
                            }
                        }
                    }

                    Button(action: { showingProductPicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(DesignSystem.primaryColor)
                            Text("添加商品")
                                .font(.system(size: DesignSystem.bodyFont))
                        }
                    }
                }

                // 总金额
                Section {
                    HStack {
                        Text("订单总额")
                            .font(.system(size: DesignSystem.bodyFont, weight: .semibold))

                        Spacer()

                        Text(totalAmount.currencyString)
                            .font(.system(size: DesignSystem.titleFont, weight: .bold))
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                }
            }
            .navigationTitle("创建订单")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.system(size: DesignSystem.bodyFont))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("提交") {
                        submitOrder()
                    }
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                    .disabled(viewModel.isLoading || cartItems.isEmpty)
                }
            }
            .sheet(isPresented: $showingProductPicker) {
                ProductPickerView(viewModel: productViewModel) { product in
                    addProduct(product)
                }
            }
            .sheet(isPresented: $showingCustomerPicker) {
                CustomerPickerView(viewModel: customerViewModel) { customer in
                    selectedCustomer = customer
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
        .task {
            await productViewModel.loadProducts()
            await customerViewModel.loadCustomers()
        }
    }

    private func addProduct(_ product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
        }
    }

    private func updateQuantity(for item: CartItem, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if quantity > 0 {
                cartItems[index].quantity = quantity
            } else {
                cartItems.remove(at: index)
            }
        }
    }

    private func removeItem(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }

    private func submitOrder() {
        guard !cartItems.isEmpty else {
            alertMessage = "请添加商品"
            showingAlert = true
            return
        }

        Task {
            let order = await viewModel.createOrder(
                customerId: selectedCustomer?.id,
                customerName: selectedCustomer?.name,
                paymentType: selectedPaymentType,
                items: cartItems
            )

            if order != nil {
                dismiss()
            } else if let error = viewModel.errorMessage {
                alertMessage = error
                showingAlert = true
            }
        }
    }
}

// MARK: - 购物车商品行
struct CartItemRow: View {
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.product.name)
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(DesignSystem.dangerColor)
                }
            }

            HStack {
                Text(item.product.price.currencyString)
                    .font(.system(size: DesignSystem.captionFont))
                    .foregroundColor(DesignSystem.secondaryTextColor)

                Spacer()

                // 数量调整
                HStack(spacing: 12) {
                    Button(action: { onQuantityChange(item.quantity - 1) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.primaryColor)
                    }

                    Text("\(item.quantity)")
                        .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                        .frame(minWidth: 30)

                    Button(action: { onQuantityChange(item.quantity + 1) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                }

                Text(item.subtotal.currencyString)
                    .font(.system(size: DesignSystem.bodyFont, weight: .bold))
                    .foregroundColor(DesignSystem.primaryColor)
                    .frame(minWidth: 80, alignment: .trailing)
            }
        }
    }
}

// MARK: - 产品选择器
struct ProductPickerView: View {
    @ObservedObject var viewModel: ProductViewModel
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Product) -> Void

    var body: some View {
        NavigationView {
            List(viewModel.products) { product in
                Button(action: {
                    onSelect(product)
                    dismiss()
                }) {
                    ProductRow(product: product)
                }
            }
            .navigationTitle("选择产品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 客户选择器
struct CustomerPickerView: View {
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Customer) -> Void

    var body: some View {
        NavigationView {
            List(viewModel.customers) { customer in
                Button(action: {
                    onSelect(customer)
                    dismiss()
                }) {
                    CustomerRow(customer: customer)
                }
            }
            .navigationTitle("选择客户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}
