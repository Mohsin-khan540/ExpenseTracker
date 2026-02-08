//
//  PreviewHelpers.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 25/12/2025.
//

import Foundation
import SwiftData

enum PreviewHelpers {

    static let container: ModelContainer = {
           try! ModelContainer(for: TransactionEntity.self)
       }()

       static let context: ModelContext = {
           container.mainContext
       }()

       static let transactionViewModel: TransactionViewModel = {
           TransactionViewModel(context: context)
       }()
}

