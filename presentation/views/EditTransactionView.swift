//
//  EditTransactionView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Sheet view for editing an existing transaction
struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: FinanceViewModel
    let transaction: Transaction
    
    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var date: Date = Date()
    @State private var category: String = ""
    @State private var showingDeleteAlert = false
    
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
                        
                        // Delete Button
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Hapus Transaksi")
                            }
                            .font(.headline)
                            .foregroundStyle(Color("expenseRed"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("expenseRed").opacity(0.1))
                            )
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Transaksi")
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
            .onAppear {
                loadTransaction()
            }
            .alert("Hapus Transaksi?", isPresented: $showingDeleteAlert) {
                Button("Batal", role: .cancel) { }
                Button("Hapus", role: .destructive) {
                    deleteTransaction()
                }
            } message: {
                Text("Transaksi ini akan dihapus secara permanen.")
            }
        }
    }
    
    private func loadTransaction() {
        name = transaction.name
        amountText = transaction.amount.formattedWithSeparator()
        transactionType = transaction.type
        date = transaction.date
        category = transaction.category ?? ""
    }
    
    private func saveTransaction() {
        viewModel.updateTransaction(
            transaction,
            name: name.trimmingCharacters(in: .whitespaces),
            amount: amount,
            type: transactionType,
            date: date,
            category: category.isEmpty ? nil : category.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
    
    private func deleteTransaction() {
        viewModel.deleteTransaction(transaction)
        dismiss()
    }
}

#Preview {
    EditTransactionView(
        viewModel: FinanceViewModel(),
        transaction: Transaction(name: "Kopi", amount: 25000, type: .expense)
    )
}
