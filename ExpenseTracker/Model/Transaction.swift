//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 20/12/2025.
//
import Foundation
import FirebaseFirestore

enum TransactionType : String , Codable{
    case income
    case expense
}

enum ExpenseCategory : String , Codable , CaseIterable{
    case food
    case transport
    case shopping
    case bills
    case entertainment
    case health
    case education
    case groceries
    case rent
    case travel
    case utilities
    case savings
    case others
}
enum IncomeCategory: String, Codable, CaseIterable {
    case salary
    case investments
    case others
}


struct Transaction : Identifiable , Codable{
    
    var id : String
    var userId : String
    
    var type : TransactionType
    var amount : Double
    
    var title: String
    var category : String
    
    var date : Date
    var createdAt : Date
    
    var note : String?
    var isPending : Bool
}
