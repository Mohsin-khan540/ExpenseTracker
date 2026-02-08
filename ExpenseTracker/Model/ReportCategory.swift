//
//  ReportCategory.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 31/12/2025.
//

import Foundation
struct CategoryReportItem: Identifiable , Equatable{
    let id = UUID()
    let category: String
    let percentage: Double
}
