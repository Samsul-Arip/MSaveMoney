//
//  TransactionListView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Date filter options
enum DateFilter: String, CaseIterable {
    case all = "Semua"
    case thisMonth = "Bulan Ini"
    case lastMonth = "Bulan Lalu"
    case custom = "Pilih Tanggal"
}

/// Full transaction history view with date grouping, tap-to-edit, and swipe actions
struct TransactionListView: View {
    @Bindable var viewModel: FinanceViewModel
    @State private var showingAddTransaction = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedFilter: DateFilter = .all
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    @State private var showingDatePicker = false
    
    private var filteredTransactions: [(date: Date, transactions: [Transaction])] {
        let calendar = Calendar.current
        
        switch selectedFilter {
        case .all:
            return viewModel.transactionsGroupedByDate
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
            return filterByDateRange(from: startOfMonth, to: Date())
        case .lastMonth:
            let now = Date()
            let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth) ?? now
            let endOfLastMonth = calendar.date(byAdding: .day, value: -1, to: startOfThisMonth) ?? now
            return filterByDateRange(from: startOfLastMonth, to: endOfLastMonth)
        case .custom:
            return filterByDateRange(from: startDate, to: endDate)
        }
    }
    
    private func filterByDateRange(from start: Date, to end: Date) -> [(date: Date, transactions: [Transaction])] {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: end) ?? end)
        
        return viewModel.transactionsGroupedByDate.compactMap { group in
            let filtered = group.transactions.filter { transaction in
                transaction.date >= startDay && transaction.date < endDay
            }
            return filtered.isEmpty ? nil : (date: group.date, transactions: filtered)
        }
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Color("surfaceBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Filter Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DateFilter.allCases, id: \.self) { filter in
                            Button {
                                withAnimation {
                                    selectedFilter = filter
                                    if filter == .custom {
                                        showingDatePicker = true
                                    }
                                }
                            } label: {
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedFilter == filter ? Color("budgetBlue") : Color("cardBackground"))
                                    )
                                    .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color("surfaceBackground"))
                
                // Custom date range display
                if selectedFilter == .custom {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(Color("budgetBlue"))
                            
                            Text("\(formatShortDate(startDate)) - \(formatShortDate(endDate))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("cardBackground"))
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                if viewModel.transactions.isEmpty {
                    // Empty State
                    Spacer()
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
                    Spacer()
                } else if filteredTransactions.isEmpty {
                    // No results for filter
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary.opacity(0.4))
                        
                        Text("Tidak ada transaksi")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Tidak ada transaksi pada periode ini")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTransactions, id: \.date) { group in
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
        .sheet(isPresented: $showingDatePicker) {
            DateRangePickerView(startDate: $startDate, endDate: $endDate)
        }
    }
}

/// Date range picker sheet
struct DateRangePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dari Tanggal") {
                    DatePicker("Mulai", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                
                Section("Sampai Tanggal") {
                    DatePicker("Akhir", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
            }
            .navigationTitle("Pilih Rentang Tanggal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Selesai") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView(viewModel: FinanceViewModel())
    }
}


