//
//  TransactionEntity.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 21/12/2025.
//

// this model is just for offline system user will easily perform transaction in offline mode because without this file firestore work only offline the data will be lost if we donot manage through swiftdata(very best for offline system)

import Foundation
import SwiftData

@Model
class TransactionEntity{
    
    @Attribute(.unique) var id : String
    var userId : String
    var type : String
    var amount : Double
    var title: String
    var category : String
    var date : Date
    var createdAt : Date
    var note : String?
    var isPending : Bool
    
    init(id: String, userId: String, type: String, amount: Double, title: String, category: String, date: Date, createdAt: Date, note: String? = nil, isPending: Bool) {
        self.id = id
        self.userId = userId
        self.type = type
        self.amount = amount
        self.title = title
        self.category = category
        self.date = date
        self.createdAt = createdAt
        self.note = note
        self.isPending = isPending
    }
}
