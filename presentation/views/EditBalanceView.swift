//
//  EditBalanceView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Sheet for editing total balance and monthly budget target
struct EditBalanceView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: FinanceViewModel
    
    @State private var balanceText: String = ""
    @State private var targetText: String = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case balance, target
    }
    
    private var balance: Double {
        CurrencyInputHelper.parseInput(balanceText)
    }
    
    private var target: Double {
        CurrencyInputHelper.parseInput(targetText)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("surfaceBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 48))
                                .foregroundStyle(Color("budgetBlue"))
                            
                            Text("Pengaturan Anggaran")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Atur total saldo dan target anggaran bulanan Anda")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Balance Input
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Total Saldo", systemImage: "wallet.pass.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color("incomeGreen"))
                            
                            Text("Saldo Anda saat ini")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("Rp")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                
                                TextField("0", text: $balanceText)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .balance)
                                    .onChange(of: balanceText) { oldValue, newValue in
                                        let formatted = CurrencyInputHelper.formatInput(newValue)
                                        if formatted != newValue {
                                            balanceText = formatted
                                        }
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("cardBackground"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("incomeGreen").opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Target Input
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Target Anggaran Bulanan", systemImage: "target")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color("budgetBlue"))
                            
                            Text("Jumlah maksimum yang ingin Anda belanjakan per bulan")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("Rp")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                
                                TextField("0", text: $targetText)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .target)
                                    .onChange(of: targetText) { oldValue, newValue in
                                        let formatted = CurrencyInputHelper.formatInput(newValue)
                                        if formatted != newValue {
                                            targetText = formatted
                                        }
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("cardBackground"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("budgetBlue").opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Save Button
                        Button {
                            saveSettings()
                        } label: {
                            Text("Simpan Perubahan")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color("budgetBlue"))
                                )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Pengaturan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
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
                loadCurrentValues()
            }
        }
    }
    
    private func loadCurrentValues() {
        balanceText = viewModel.totalBalance > 0 ? viewModel.totalBalance.formattedWithSeparator() : ""
        targetText = viewModel.monthlyTarget > 0 ? viewModel.monthlyTarget.formattedWithSeparator() : ""
    }
    
    private func saveSettings() {
        viewModel.updateBudgetSettings(totalBalance: balance, monthlyTarget: target)
        dismiss()
    }
}

#Preview {
    EditBalanceView(viewModel: FinanceViewModel())
}
