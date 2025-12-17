//
//  BudgetSettings.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import Foundation
import SwiftData

/// Stores the user's budget configuration: total balance and monthly target
@Model
final class BudgetSettings {
    var id: UUID
    var totalBalance: Double
    var monthlyTarget: Double
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        totalBalance: Double = 0.0,
        monthlyTarget: Double = 0.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.totalBalance = totalBalance
        self.monthlyTarget = monthlyTarget
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Updates the settings with new values
    func update(totalBalance: Double? = nil, monthlyTarget: Double? = nil) {
        if let balance = totalBalance {
            self.totalBalance = balance
        }
        if let target = monthlyTarget {
            self.monthlyTarget = target
        }
        self.updatedAt = Date()
    }
}
