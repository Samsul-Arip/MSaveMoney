//
//  TransactionRowView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Individual transaction row component showing date, name, and amount
struct TransactionRowView: View {
    let transaction: Transaction
    
    private var amountColor: Color {
        transaction.type == .expense ? Color("expenseRed") : Color("incomeGreen")
    }
    
    private var amountPrefix: String {
        transaction.type == .expense ? "- " : "+ "
    }
    
    private var iconName: String {
        transaction.type == .expense ? "arrow.up.right" : "arrow.down.left"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(amountColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(amountColor)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                
                Text(transaction.date.formattedRelative())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(amountPrefix + transaction.amount.formattedCurrency())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack {
        TransactionRowView(
            transaction: Transaction(name: "Salary", amount: 5000000, type: .income)
        )
        
        Divider()
        
        TransactionRowView(
            transaction: Transaction(name: "Coffee at Starbucks", amount: 75000, type: .expense)
        )
        
        Divider()
        
        TransactionRowView(
            transaction: Transaction(name: "Groceries", amount: 350000, type: .expense)
        )
    }
    .padding()
}
