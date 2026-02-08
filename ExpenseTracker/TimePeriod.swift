//
//  TimePeriod.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 28/12/2025.
//

import Foundation

enum TimePeriod: String, CaseIterable {
    case all = "All"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var title: String {
        switch self {
        case .all: return "All Time"
        case .daily: return "Today"
        case .weekly: return "This Week"
        case .monthly: return "This Month"
        }
    }
}
