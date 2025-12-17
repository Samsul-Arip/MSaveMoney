//
//  BalanceCardView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Prominent card displaying the total wallet balance with green accent
struct BalanceCardView: View {
    let balance: Double
    var onTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Total Saldo")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: "wallet.pass.fill")
                    .font(.title2)
                    .foregroundStyle(Color("incomeGreen"))
            }
            
            Text(balance.formattedCurrency())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color("incomeGreen"))
                .contentTransition(.numericText())
            
            Text("Ketuk untuk edit saldo")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cardBackground"))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    BalanceCardView(balance: 20000000)
        .padding()
}
