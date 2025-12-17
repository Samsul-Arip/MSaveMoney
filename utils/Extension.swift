//
//  Extension.swift
//  MSaveMoney
//
//  Created by Samsul Aripin on 01/03/25.
//

import SwiftUI

// MARK: - Text Styling Extensions

extension Text {
    func styleGray16Bold() -> Text {
        self.foregroundStyle(Color("gray1"))
            .font(.system(size: 16, weight: .bold, design: .default))
    }
    
    func styleBlack20Bold() -> Text {
        self.foregroundStyle(.black)
            .font(.system(size: 20, weight: .bold, design: .default))
    }
    
    func styleGray16Regular() -> Text {
        self.foregroundStyle(Color("gray1"))
            .font(.system(size: 16, weight: .regular, design: .default))
    }
    
    func styleRoundedBold(_ size: CGFloat) -> Text {
        self.font(.system(size: size, weight: .bold, design: .rounded))
    }
    
    func styleRoundedMedium(_ size: CGFloat) -> Text {
        self.font(.system(size: size, weight: .medium, design: .rounded))
    }
}

// MARK: - Double Currency Formatting

extension Double {
    /// Formats as Indonesian Rupiah (Rp 1.500.000)
    func formattedCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        
        let formattedNumber = formatter.string(from: NSNumber(value: self)) ?? "0"
        return "Rp \(formattedNumber)"
    }
    
    /// Short form for chart axis labels (e.g., 1.5M, 500K)
    func shortFormattedCurrency() -> String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.0fK", self / 1_000)
        } else {
            return String(format: "%.0f", self)
        }
    }
    
    /// Formats number with thousand separators only (without Rp prefix)
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// MARK: - Currency Input Helper

/// Helper class for formatting currency input in real-time
class CurrencyInputHelper {
    
    /// Formats a string as currency while typing (e.g., "8000000" → "8.000.000")
    static func formatInput(_ input: String) -> String {
        // Remove all non-digit characters
        let digits = input.filter { $0.isNumber }
        
        // Convert to number and format
        guard let number = Double(digits), number > 0 else {
            return ""
        }
        
        return number.formattedWithSeparator()
    }
    
    /// Parses a formatted string back to Double (e.g., "8.000.000" → 8000000.0)
    static func parseInput(_ input: String) -> Double {
        // Remove all non-digit characters
        let digits = input.filter { $0.isNumber }
        return Double(digits) ?? 0
    }
}

// MARK: - Date Formatting Extensions

extension Date {
    /// Formats as relative date (Today, Yesterday, or full date)
    func formattedRelative() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Hari ini, " + formattedTime()
        } else if calendar.isDateInYesterday(self) {
            return "Kemarin, " + formattedTime()
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            formatter.locale = Locale(identifier: "id_ID")
            return formatter.string(from: self)
        }
    }
    
    /// Formats time only (e.g., 14:30)
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// Formats for section headers (e.g., "Today", "Yesterday", "14 Februari 2025")
    func formattedSectionHeader() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Hari ini"
        } else if calendar.isDateInYesterday(self) {
            return "Kemarin"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM yyyy"
            formatter.locale = Locale(identifier: "id_ID")
            return formatter.string(from: self)
        }
    }
    
    /// Formats as full Indonesian date (e.g., "Kamis, 14 Februari 2025")
    func formattedFullDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: self)
    }
    
    /// Gets current month name (e.g., "Januari 2025")
    func formattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: self)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies the standard card style with rounded corners and shadow
    func cardStyle() -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("cardBackground"))
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
            )
    }
}
