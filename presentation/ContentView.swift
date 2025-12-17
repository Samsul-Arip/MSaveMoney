//
//  ContentView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 25/02/25.
//

import SwiftUI

/// Main content view - redirects to DashboardView
struct ContentView: View {
    var body: some View {
        DashboardView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, BudgetSettings.self], inMemory: true)
}

