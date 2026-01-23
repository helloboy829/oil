//
//  CustomerFormView.swift
//  OilSalesApp
//
//  客户表单视图（新增/编辑）
//

import SwiftUI

struct CustomerFormView: View {
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) private var dismiss

    let customer: Customer?

    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var isMonthly = false
    @State private var creditLimit = ""
    @State private var currentDebt = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    init(viewModel: CustomerViewModel, customer: Customer? = nil) {
        self.viewModel = viewModel
        self.customer = customer

        if let customer = customer {
            _name = State(initialValue: customer.name)
            _phone = State(initialValue: customer.phone ?? "")
            _address = State(initialValue: customer.address ?? "")
            _isMonthly = State(initialValue: customer.isMonthlyCustomer)
            _creditLimit = State(initialValue: customer.creditLimit != nil ? String(customer.creditLimit!) : "")
            _currentDebt = State(initialValue: customer.currentDebt != nil ? String(customer.currentDebt!) : "")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息").font(.system(size: DesignSystem.bodyFont))) {
                    TextField("客户名称", text: $name)
                        .font(.system(size: DesignSystem.bodyFont))

                    TextField("联系电话", text: $phone)
                        .font(.system(size: DesignSystem.bodyFont))
                        .keyboardType(.phonePad)

                    TextField("地址", text: $address)
                        .font(.system(size: DesignSystem.bodyFont))
                }

                Section(header: Text("月结设置").font(.system(size: DesignSystem.bodyFont))) {
                    Toggle("月结客户", isOn: $isMonthly)
                        .font(.system(size: DesignSystem.bodyFont))

                    if isMonthly {
                        TextField("信用额度", text: $creditLimit)
                            .font(.system(size: DesignSystem.bodyFont))
                            .keyboardType(.decimalPad)

                        TextField("当前欠款", text: $currentDebt)
                            .font(.system(size: DesignSystem.bodyFont))
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle(customer == nil ? "新增客户" : "编辑客户")
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
                        saveCustomer()
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

    private func saveCustomer() {
        guard name.isNotEmpty else {
            alertMessage = "请输入客户名称"
            showingAlert = true
            return
        }

        if !phone.isEmpty && !phone.isValidPhone {
            alertMessage = "请输入有效的手机号"
            showingAlert = true
            return
        }

        let creditLimitValue = isMonthly && !creditLimit.isEmpty ? Double(creditLimit) : nil
        let currentDebtValue = isMonthly && !currentDebt.isEmpty ? Double(currentDebt) : nil

        Task {
            let success: Bool
            if let customer = customer {
                success = await viewModel.updateCustomer(
                    id: customer.id,
                    name: name,
                    phone: phone.isEmpty ? nil : phone,
                    address: address.isEmpty ? nil : address,
                    isMonthly: isMonthly,
                    creditLimit: creditLimitValue,
                    currentDebt: currentDebtValue
                )
            } else {
                success = await viewModel.createCustomer(
                    name: name,
                    phone: phone.isEmpty ? nil : phone,
                    address: address.isEmpty ? nil : address,
                    isMonthly: isMonthly,
                    creditLimit: creditLimitValue,
                    currentDebt: currentDebtValue
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
