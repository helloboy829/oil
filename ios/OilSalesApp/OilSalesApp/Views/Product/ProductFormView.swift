//
//  ProductFormView.swift
//  OilSalesApp
//
//  产品表单视图（新增/编辑）
//

import SwiftUI

struct ProductFormView: View {
    @ObservedObject var viewModel: ProductViewModel
    @Environment(\.dismiss) private var dismiss

    let product: Product?  // nil表示新增，非nil表示编辑

    @State private var name = ""
    @State private var code = ""
    @State private var price = ""
    @State private var stock = ""
    @State private var unit = "升"
    @State private var showingAlert = false
    @State private var alertMessage = ""

    init(viewModel: ProductViewModel, product: Product? = nil) {
        self.viewModel = viewModel
        self.product = product

        // 如果是编辑模式，初始化表单数据
        if let product = product {
            _name = State(initialValue: product.name)
            _code = State(initialValue: product.code)
            _price = State(initialValue: String(product.price))
            _stock = State(initialValue: String(product.stock))
            _unit = State(initialValue: product.unit)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息").font(.system(size: DesignSystem.bodyFont))) {
                    TextField("产品名称", text: $name)
                        .font(.system(size: DesignSystem.bodyFont))

                    TextField("产品编码", text: $code)
                        .font(.system(size: DesignSystem.bodyFont))

                    TextField("单价", text: $price)
                        .font(.system(size: DesignSystem.bodyFont))
                        .keyboardType(.decimalPad)

                    TextField("库存", text: $stock)
                        .font(.system(size: DesignSystem.bodyFont))
                        .keyboardType(.numberPad)

                    TextField("单位", text: $unit)
                        .font(.system(size: DesignSystem.bodyFont))
                }
            }
            .navigationTitle(product == nil ? "新增产品" : "编辑产品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.system(size: DesignSystem.bodyFont))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProduct()
                    }
                    .font(.system(size: DesignSystem.bodyFont, weight: .semibold))
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveProduct() {
        // 验证输入
        guard name.isNotEmpty else {
            alertMessage = "请输入产品名称"
            showingAlert = true
            return
        }

        guard code.isNotEmpty else {
            alertMessage = "请输入产品编码"
            showingAlert = true
            return
        }

        guard let priceValue = Double(price), priceValue > 0 else {
            alertMessage = "请输入有效的单价"
            showingAlert = true
            return
        }

        guard let stockValue = Int(stock), stockValue >= 0 else {
            alertMessage = "请输入有效的库存"
            showingAlert = true
            return
        }

        guard unit.isNotEmpty else {
            alertMessage = "请输入单位"
            showingAlert = true
            return
        }

        // 保存
        Task {
            let success: Bool
            if let product = product {
                // 编辑
                success = await viewModel.updateProduct(
                    id: product.id,
                    name: name,
                    code: code,
                    price: priceValue,
                    stock: stockValue,
                    unit: unit,
                    categoryId: nil
                )
            } else {
                // 新增
                success = await viewModel.createProduct(
                    name: name,
                    code: code,
                    price: priceValue,
                    stock: stockValue,
                    unit: unit,
                    categoryId: nil
                )
            }

            if success {
                dismiss()
            } else if let error = viewModel.errorMessage {
                alertMessage = error
                showingAlert = true
            }
        }
    }
}
