//
//  TodaysExpensesView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Card showing today's spending summary with daily budget target
struct TodaysExpensesView: View {
    let expenses: [Transaction]
    let total: Double
    let dailyTarget: Double
    let isOverBudget: Bool
    let difference: Double
    
    private var statusColor: Color {
        if dailyTarget <= 0 {
            return Color("expenseRed")
        }
        return isOverBudget ? Color("expenseRed") : Color("incomeGreen")
    }
    
    private var statusIcon: String {
        if dailyTarget <= 0 {
            return "exclamationmark.triangle.fill"
        }
        return isOverBudget ? "arrow.up.circle.fill" : "checkmark.circle.fill"
    }
    
    private var statusText: String {
        if dailyTarget <= 0 {
            return "Anggaran bulan ini habis!"
        }
        return isOverBudget ? "Melebihi target harian!" : "Masih dalam target"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Pengeluaran Hari Ini")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundStyle(Color("expenseRed"))
            }
            
            if expenses.isEmpty && dailyTarget > 0 {
                // Empty state with daily target info
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundStyle(Color("incomeGreen"))
                    
                    Text("Belum ada pengeluaran hari ini")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Daily target info
                    HStack(spacing: 4) {
                        Text("Target hari ini:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(dailyTarget.formattedCurrency())
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("budgetBlue"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                // Total spent today
                Text(total.formattedCurrency())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("expenseRed"))
                
                // Daily target comparison
                HStack(spacing: 8) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 14))
                        .foregroundStyle(statusColor)
                    
                    Text(statusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(statusColor)
                    
                    Spacer()
                    
                    // Difference badge
                    if dailyTarget > 0 {
                        HStack(spacing: 2) {
                            if isOverBudget {
                                Text("-")
                            }
                            Text(abs(difference).formattedCurrency())
                        }
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor)
                        )
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusColor.opacity(0.1))
                )
                
                // Daily target info
                HStack {
                    Text("Target harian:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(dailyTarget.formattedCurrency())
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color("budgetBlue"))
                }
                
                if !expenses.isEmpty {
                    Divider()
                    
                    // Expense items
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(expenses.prefix(3)) { expense in
                            HStack {
                                Text(expense.name)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(expense.amount.formattedCurrency())
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color("expenseRed"))
                            }
                        }
                        
                        if expenses.count > 3 {
                            Text("+ \(expenses.count - 3) lainnya")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cardBackground"))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .overlay(
            // Warning border when over budget
            RoundedRectangle(cornerRadius: 16)
                .stroke(isOverBudget ? Color("expenseRed").opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        TodaysExpensesView(
            expenses: [],
            total: 0,
            dailyTarget: 50000,
            isOverBudget: false,
            difference: 50000
        )
        
        TodaysExpensesView(
            expenses: [
                Transaction(name: "Kopi", amount: 25000, type: .expense),
                Transaction(name: "Makan Siang", amount: 50000, type: .expense)
            ],
            total: 75000,
            dailyTarget: 100000,
            isOverBudget: false,
            difference: 25000
        )
        
        TodaysExpensesView(
            expenses: [
                Transaction(name: "Kopi", amount: 25000, type: .expense),
                Transaction(name: "Makan Siang", amount: 80000, type: .expense),
                Transaction(name: "Transport", amount: 30000, type: .expense)
            ],
            total: 135000,
            dailyTarget: 100000,
            isOverBudget: true,
            difference: -35000
        )
    }
    .padding()
}

