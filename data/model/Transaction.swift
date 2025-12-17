//
//  Transaction.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import Foundation
import SwiftData

/// Represents a single financial transaction (income or expense)
@Model
final class Transaction {
    var id: UUID
    var name: String
    var amount: Double
    var date: Date
    var type: TransactionType
    var category: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        date: Date = Date(),
        type: TransactionType,
        category: String? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.type = type
        self.category = category
    }
}

/// Transaction type: income adds to balance, expense subtracts
enum TransactionType: String, Codable, CaseIterable {
    case income = "Pemasukan"
    case expense = "Pengeluaran"
    
    var displayName: String {
        rawValue
    }
    
    var isExpense: Bool {
        self == .expense
    }
}
