//
//  SpendingChartView.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 17/12/24.
//

import SwiftUI
import Charts

/// Bar chart showing spending over the last 7 days
struct SpendingChartView: View {
    let data: [DailySpending]
    
    var maxAmount: Double {
        data.map { $0.amount }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("7 Hari Terakhir")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundStyle(Color("budgetBlue"))
            }
            
            if data.allSatisfy({ $0.amount == 0 }) {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary.opacity(0.5))
                    
                    Text("Belum ada data pengeluaran")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("budgetBlue"), Color("budgetBlue").opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .frame(height: 100)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(amount.shortFormattedCurrency())
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let day = value.as(String.self) {
                                Text(day)
                                    .font(.caption2)
                            }
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
    }
}

#Preview {
    VStack(spacing: 20) {
        SpendingChartView(data: [
            DailySpending(day: "Mon", amount: 50000, date: Date()),
            DailySpending(day: "Tue", amount: 75000, date: Date()),
            DailySpending(day: "Wed", amount: 30000, date: Date()),
            DailySpending(day: "Thu", amount: 100000, date: Date()),
            DailySpending(day: "Fri", amount: 45000, date: Date()),
            DailySpending(day: "Sat", amount: 80000, date: Date()),
            DailySpending(day: "Today", amount: 25000, date: Date())
        ])
        
        SpendingChartView(data: [])
    }
    .padding()
}
