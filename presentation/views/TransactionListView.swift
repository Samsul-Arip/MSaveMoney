//
//  TransactionListView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Full transaction history view with date grouping, tap-to-edit, and swipe actions
struct TransactionListView: View {
    @Bindable var viewModel: FinanceViewModel
    @State private var showingAddTransaction = false
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        ZStack {
            Color("surfaceBackground")
                .ignoresSafeArea()
            
            if viewModel.transactions.isEmpty {
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary.opacity(0.4))
                    
                    Text("Belum Ada Transaksi")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text("Riwayat transaksi Anda akan muncul di sini")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                    
                    Button {
                        showingAddTransaction = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Tambah Transaksi")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color("budgetBlue"))
                        )
                    }
                    .padding(.top, 8)
                }
            } else {
                List {
                    ForEach(viewModel.transactionsGroupedByDate, id: \.date) { group in
                        Section {
                            ForEach(group.transactions) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .listRowBackground(Color("cardBackground"))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTransaction = transaction
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                viewModel.deleteTransaction(transaction)
                                            }
                                        } label: {
                                            Label("Hapus", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            selectedTransaction = transaction
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(Color("budgetBlue"))
                                    }
                            }
                        } header: {
                            Text(group.date.formattedSectionHeader())
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .textCase(nil)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Semua Transaksi")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddTransaction = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("budgetBlue"))
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .sheet(item: $selectedTransaction) { transaction in
            EditTransactionView(viewModel: viewModel, transaction: transaction)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView(viewModel: FinanceViewModel())
    }
}

