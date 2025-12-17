//
//  FinanceViewModel.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import Foundation
import SwiftData
import SwiftUI

/// Main ViewModel for the finance app - handles all business logic
@Observable
final class FinanceViewModel {
    private var modelContext: ModelContext?
    
    // MARK: - Published Properties
    var transactions: [Transaction] = []
    var budgetSettings: BudgetSettings?
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Initialization
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }
    
    // MARK: - Data Fetching
    func fetchData() {
        fetchTransactions()
        fetchBudgetSettings()
    }
    
    private func fetchTransactions() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            transactions = try context.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
        }
    }
    
    private func fetchBudgetSettings() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<BudgetSettings>()
        
        do {
            let settings = try context.fetch(descriptor)
            if let existing = settings.first {
                budgetSettings = existing
            } else {
                // Create default settings if none exist
                let newSettings = BudgetSettings(
                    totalBalance: 0.0,
                    monthlyTarget: 1000000.0
                )
                context.insert(newSettings)
                try context.save()
                budgetSettings = newSettings
            }
        } catch {
            errorMessage = "Failed to fetch budget settings: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Transaction Operations
    
    /// Add a new transaction
    func addTransaction(name: String, amount: Double, type: TransactionType, date: Date = Date(), category: String? = nil) {
        guard let context = modelContext else { return }
        
        let transaction = Transaction(
            name: name,
            amount: amount,
            date: date,
            type: type,
            category: category
        )
        
        context.insert(transaction)
        
        // Update total balance based on transaction type
        if type == .expense {
            budgetSettings?.totalBalance -= amount
        } else {
            budgetSettings?.totalBalance += amount
        }
        budgetSettings?.updatedAt = Date()
        
        do {
            try context.save()
            fetchTransactions()
        } catch {
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
        }
    }
    
    /// Delete a transaction
    func deleteTransaction(_ transaction: Transaction) {
        guard let context = modelContext else { return }
        
        // Reverse the balance change
        if transaction.type == .expense {
            budgetSettings?.totalBalance += transaction.amount
        } else {
            budgetSettings?.totalBalance -= transaction.amount
        }
        budgetSettings?.updatedAt = Date()
        
        context.delete(transaction)
        
        do {
            try context.save()
            fetchTransactions()
        } catch {
            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
        }
    }
    
    /// Update an existing transaction
    func updateTransaction(_ transaction: Transaction, name: String, amount: Double, type: TransactionType, date: Date, category: String?) {
        guard let context = modelContext else { return }
        
        // First, reverse the old balance change
        if transaction.type == .expense {
            budgetSettings?.totalBalance += transaction.amount
        } else {
            budgetSettings?.totalBalance -= transaction.amount
        }
        
        // Update the transaction
        transaction.name = name
        transaction.amount = amount
        transaction.type = type
        transaction.date = date
        transaction.category = category
        
        // Apply the new balance change
        if type == .expense {
            budgetSettings?.totalBalance -= amount
        } else {
            budgetSettings?.totalBalance += amount
        }
        budgetSettings?.updatedAt = Date()
        
        do {
            try context.save()
            fetchTransactions()
        } catch {
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
        }
    }
    
    /// Delete transactions at specific indices
    func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            deleteTransaction(transactions[index])
        }
    }
    
    // MARK: - Budget Operations
    
    /// Update budget settings
    func updateBudgetSettings(totalBalance: Double? = nil, monthlyTarget: Double? = nil) {
        guard let context = modelContext else { return }
        
        budgetSettings?.update(totalBalance: totalBalance, monthlyTarget: monthlyTarget)
        
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to update budget settings: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Computed Properties
    
    /// Get today's expenses only
    var todaysExpenses: [Transaction] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: today) && transaction.type == .expense
        }
    }
    
    /// Total spent today
    var todaysTotalSpending: Double {
        todaysExpenses.reduce(0) { $0 + $1.amount }
    }
    
    /// Get this month's expenses
    var thisMonthsExpenses: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        return transactions.filter { transaction in
            transaction.date >= startOfMonth && transaction.type == .expense
        }
    }
    
    /// Total spent this month
    var totalSpentThisMonth: Double {
        thisMonthsExpenses.reduce(0) { $0 + $1.amount }
    }
    
    /// Remaining budget for this month
    var remainingBudget: Double {
        max(0, (budgetSettings?.monthlyTarget ?? 0) - totalSpentThisMonth)
    }
    
    /// Budget progress (0.0 to 1.0)
    var budgetProgress: Double {
        guard let target = budgetSettings?.monthlyTarget, target > 0 else { return 0 }
        return min(1.0, totalSpentThisMonth / target)
    }
    
    /// Total balance
    var totalBalance: Double {
        budgetSettings?.totalBalance ?? 0
    }
    
    /// Monthly target
    var monthlyTarget: Double {
        budgetSettings?.monthlyTarget ?? 0
    }
    
    // MARK: - Daily Budget Target
    
    /// Total number of days in the current month
    var totalDaysInMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let range = calendar.range(of: .day, in: .month, for: now) else { return 30 }
        return range.count
    }
    
    /// Daily budget target = monthly target ÷ total days in month
    var dailyBudgetTarget: Double {
        guard totalDaysInMonth > 0 else { return 0 }
        return monthlyTarget / Double(totalDaysInMonth)
    }
    
    /// Whether today's spending exceeds the daily budget target
    var isDailyBudgetExceeded: Bool {
        todaysTotalSpending > dailyBudgetTarget && dailyBudgetTarget > 0
    }
    
    /// Daily budget difference (positive = under budget, negative = over budget)
    var dailyBudgetDifference: Double {
        dailyBudgetTarget - todaysTotalSpending
    }
    
    /// Status text for daily budget
    var dailyBudgetStatusText: String {
        if dailyBudgetTarget <= 0 {
            return "Target habis"
        } else if isDailyBudgetExceeded {
            return "Melebihi target!"
        } else {
            return "Masih aman"
        }
    }
    
    // MARK: - Last 7 Days Spending Data
    
    /// Returns spending data for the last 7 days for chart display
    var last7DaysSpending: [DailySpending] {
        let calendar = Calendar.current
        var result: [DailySpending] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            
            let dayExpenses = transactions.filter { transaction in
                calendar.isDate(transaction.date, inSameDayAs: dayStart) && transaction.type == .expense
            }
            
            let total = dayExpenses.reduce(0) { $0 + $1.amount }
            let dayName = dayOffset == 0 ? "Hari ini" : dayFormatter.string(from: date)
            
            result.append(DailySpending(day: dayName, amount: total, date: date))
        }
        
        return result
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }
    
    // MARK: - Recent Transactions
    
    /// Get the most recent transactions (limited)
    func recentTransactions(limit: Int = 5) -> [Transaction] {
        Array(transactions.prefix(limit))
    }
    
    /// Group transactions by date
    var transactionsGroupedByDate: [(date: Date, transactions: [Transaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        return grouped
            .map { (date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
}

// MARK: - Supporting Types

/// Model for daily spending chart data
struct DailySpending: Identifiable {
    let id = UUID()
    let day: String
    let amount: Double
    let date: Date
}
