//
//  DashboardView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI
import SwiftData

/// Main dashboard view with Bento Grid layout showing financial overview
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = FinanceViewModel()
    @State private var showingAddTransaction = false
    @State private var showingEditBalance = false
    @State private var showingAllTransactions = false
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("surfaceBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Balance Card
                        BalanceCardView(balance: viewModel.totalBalance) {
                            showingEditBalance = true
                        }
                        
                        // Budget Progress + Today's Expenses (Bento Grid)
                        HStack(spacing: 16) {
                            BudgetProgressView(
                                spent: viewModel.totalSpentThisMonth,
                                target: viewModel.monthlyTarget,
                                remaining: viewModel.remainingBudget
                            )
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Today's Expenses
                        TodaysExpensesView(
                            expenses: viewModel.todaysExpenses,
                            total: viewModel.todaysTotalSpending,
                            dailyTarget: viewModel.dailyBudgetTarget,
                            isOverBudget: viewModel.isDailyBudgetExceeded,
                            difference: viewModel.dailyBudgetDifference
                        )
                        
                        // 7-Day Spending Chart
                        SpendingChartView(data: viewModel.last7DaysSpending)
                        
                        // Recent Transactions Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Transaksi Terbaru")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Button("Lihat Semua") {
                                    showingAllTransactions = true
                                }
                                .font(.subheadline)
                                .foregroundStyle(Color("budgetBlue"))
                            }
                            
                            if viewModel.transactions.isEmpty {
                                EmptyTransactionView()
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.recentTransactions(limit: 5)) { transaction in
                                        TransactionRowView(transaction: transaction)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                selectedTransaction = transaction
                                            }
                                        
                                        if transaction.id != viewModel.recentTransactions(limit: 5).last?.id {
                                            Divider()
                                        }
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color("cardBackground"))
                                        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                                )
                            }
                        }
                    }
                    .padding()
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddTransaction = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color("budgetBlue"), Color("budgetBlue").opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color("budgetBlue").opacity(0.4), radius: 8, x: 0, y: 4)
                                )
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("MSaveMoney")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditBalance = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingEditBalance) {
                EditBalanceView(viewModel: viewModel)
            }
            .sheet(item: $selectedTransaction) { transaction in
                EditTransactionView(viewModel: viewModel, transaction: transaction)
            }
            .navigationDestination(isPresented: $showingAllTransactions) {
                TransactionListView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.configure(with: modelContext)
        }
    }
}

/// Empty state view for transactions
struct EmptyTransactionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary.opacity(0.5))
            
            Text("Belum ada transaksi")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Ketuk tombol + untuk menambahkan transaksi pertama Anda")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cardBackground"))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Transaction.self, BudgetSettings.self], inMemory: true)
}
