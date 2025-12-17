//
//  BudgetProgressView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI

/// Circular progress ring showing remaining budget vs monthly target
struct BudgetProgressView: View {
    let spent: Double
    let target: Double
    let remaining: Double
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(1.0, spent / target)
    }
    
    var progressColor: Color {
        if progress >= 0.9 {
            return Color("expenseRed")
        } else if progress >= 0.7 {
            return .orange
        } else {
            return Color("budgetBlue")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Anggaran Bulanan")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundStyle(Color("budgetBlue"))
            }
            
            HStack(spacing: 16) {
                // Circular Progress Ring
                ZStack {
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: 10
                        )
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressColor,
                            style: StrokeStyle(
                                lineWidth: 10,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    
                    VStack(spacing: 2) {
                        Text("\(Int((1 - progress) * 100))%")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(progressColor)
                        
                        Text("sisa")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tersisa")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(remaining.formattedCurrency())
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(progressColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(target.formattedCurrency())
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cardBackground"))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        BudgetProgressView(spent: 300000, target: 1500000, remaining: 1200000)
        BudgetProgressView(spent: 1200000, target: 1500000, remaining: 300000)
        BudgetProgressView(spent: 1450000, target: 1500000, remaining: 50000)
    }
    .padding()
}
