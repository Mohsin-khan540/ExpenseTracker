//
//  CurrencyFormatter.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 23/12/2025.
//
import Foundation

struct CurrencyFormatter {

    static func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "-"
    }
}
