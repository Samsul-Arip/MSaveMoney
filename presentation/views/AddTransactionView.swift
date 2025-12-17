//
//  AddTransactionView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Sheet view for adding a new transaction
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: FinanceViewModel
    
    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var date: Date = Date()
    @State private var category: String = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, amount, category
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amountText.isEmpty &&
        CurrencyInputHelper.parseInput(amountText) > 0
    }
    
    private var amount: Double {
        CurrencyInputHelper.parseInput(amountText)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("surfaceBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Transaction Type Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipe")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Picker("Tipe Transaksi", selection: $transactionType) {
                                ForEach(TransactionType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Jumlah")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("Rp")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                
                                TextField("0", text: $amountText)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .amount)
                                    .foregroundStyle(transactionType == .expense ? Color("expenseRed") : Color("incomeGreen"))
                                    .onChange(of: amountText) { oldValue, newValue in
                                        let formatted = CurrencyInputHelper.formatInput(newValue)
                                        if formatted != newValue {
                                            amountText = formatted
                                        }
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("cardBackground"))
                            )
                        }
                        
                        // Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deskripsi")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            TextField("Apa yang Anda beli?", text: $name)
                                .font(.body)
                                .padding()
                                .focused($focusedField, equals: .name)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("cardBackground"))
                                )
                        }
                        
                        // Category Input (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kategori (Opsional)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            TextField("cth. Makanan, Transportasi", text: $category)
                                .font(.body)
                                .padding()
                                .focused($focusedField, equals: .category)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("cardBackground"))
                                )
                        }
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanggal")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            DatePicker(
                                "Tanggal Transaksi",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("cardBackground"))
                            )
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Tambah Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(isFormValid ? Color("budgetBlue") : .secondary)
                    .disabled(!isFormValid)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Selesai") {
                            focusedField = nil
                        }
                    }
                }
            }
        }
    }
    
    private func saveTransaction() {
        viewModel.addTransaction(
            name: name.trimmingCharacters(in: .whitespaces),
            amount: amount,
            type: transactionType,
            date: date,
            category: category.isEmpty ? nil : category.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
}

#Preview {
    AddTransactionView(viewModel: FinanceViewModel())
}
