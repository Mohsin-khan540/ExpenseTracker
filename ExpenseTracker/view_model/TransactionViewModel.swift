//
//  TransactionViewModel.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 20/12/2025.
//

import SwiftData
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class TransactionViewModel: ObservableObject {
    
    private let context: ModelContext
    init(context : ModelContext){
        self.context = context
    }
    
    
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var totalIncome : Double = 0
    @Published private(set) var totalExpense : Double = 0
    @Published private(set) var balance : Double = 0
    
    private let db = Firestore.firestore()
    
    @Published var selectedPeriod: TimePeriod = .monthly
    @Published var reportMonth = Date()
    
    var reportMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: reportMonth)
    }

    func goToPreviousMonth() {
        reportMonth = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: reportMonth
        ) ?? reportMonth
    }

    func goToNextMonth() {
        let nextMonth = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: reportMonth
        ) ?? reportMonth

        //  prevent future months
        if nextMonth <= Date() {
            reportMonth = nextMonth
        }
    }
  
    
    // this function is use for report (monthly base)
    
    func expenseCategoryPercentagesForMonth() -> [CategoryReportItem] {

        let calendar = Calendar.current
        // both condition must be tru 1 : shoud type  expense 2: should belong to selected month
        let monthExpenses = transactions.filter { tx in
            tx.type == .expense &&
            calendar.isDate(tx.date, equalTo: reportMonth, toGranularity: .month)
        }
         // if expense -> continue other wise exit (return empty array)
        guard !monthExpenses.isEmpty else { return [] }
        //add all expenses together
        let total = monthExpenses.reduce(0) { $0 + $1.amount }

        var categoryTotal: [ExpenseCategory: Double] = [:]

        for tx in monthExpenses {
            let normalized = tx.category
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            let category = ExpenseCategory(rawValue: normalized) ?? .others
            categoryTotal[category, default: 0] += tx.amount
        }

        let primaryCategories: Set<ExpenseCategory> = [
            .food, .transport, .shopping, .health, .education, .bills
        ]

        var result: [CategoryReportItem] = []
        var othersTotal: Double = 0

        for (category, amount) in categoryTotal {
            let percentage = (amount / total) * 100

            if primaryCategories.contains(category) {
                result.append(
                    CategoryReportItem(
                        category: category.rawValue.capitalized,
                        percentage: percentage
                    )
                )
            } else {
                othersTotal += amount
            }
        }

        if othersTotal > 0 {
            let percentage = (othersTotal / total) * 100
            result.append(
                CategoryReportItem(category: "Others", percentage: percentage)
            )
        }

        return result.sorted { $0.percentage > $1.percentage }
    }
    
    // {the below function(3) are use for compariosn
    
    func totalExpense(for month : Date)->Double{
        let calander = Calendar.current
        let expenses = transactions.filter{tx in
            tx.type == .expense && calander.isDate(tx.date, equalTo: month , toGranularity: .month)
        }
        return expenses.reduce(0){$0+$1.amount}
    }
    func previousMonth(from date : Date)-> Date{
        Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
    }
    func monthlyExpenseComparison() -> (
        current: Double,
        previous: Double,
        difference: Double,
        percentage: Double?
    ) {
        let currentMonthExpense = totalExpense(for: reportMonth)
        let previousMonthExpense = totalExpense(for: previousMonth(from: reportMonth))

        let difference = currentMonthExpense - previousMonthExpense

        let percentage: Double?
        if previousMonthExpense > 0 {
            percentage = (difference / previousMonthExpense) * 100
        } else {
            percentage = nil
        }

        return (
            current: currentMonthExpense,
            previous: previousMonthExpense,
            difference: difference,
            percentage: percentage
        )
    }
    // thats it }

    func filterTransactions()->[Transaction]{
        let calander = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .all:
            return transactions
        case .daily:
            return transactions.filter{
                calander.isDate($0.date, inSameDayAs: now)
            }
        case .weekly:
            return transactions.filter{
                calander.isDate($0.date, equalTo: now , toGranularity: .weekOfYear)
            }
        case .monthly:
            return transactions.filter{
                calander.isDate($0.date, equalTo: now , toGranularity: .month)
            }
        }
    }
    
    func recalculateTotals(){
        
        let filtered = filterTransactions()
        
        totalIncome = filtered
            .filter{$0.type == .income}
            .reduce(0){$0+$1.amount}
        totalExpense = filtered
            .filter{$0.type == .expense}
            .reduce(0){$0+$1.amount}
        balance = totalIncome - totalExpense
    }
    
    func isValidCategory(type : TransactionType , category : String)->Bool{
        switch type{
        case .income:
            return IncomeCategory(rawValue: category) != nil
        case .expense:
            return ExpenseCategory(rawValue: category) != nil
        }
    }
    
    func addTransaction(type : TransactionType , amount : Double ,title: String, category: String , date : Date, note : String? = nil ){
        guard amount > 0 else {return}
        guard isValidCategory(type: type, category: category) else {return}
        
        let transaction = Transaction(id: UUID().uuidString, userId: Auth.auth().currentUser?.uid ?? "", type: type, amount: amount,title: title, category: category, date: date, createdAt: Date(), note: note , isPending: true)
        
        saveToSwiftData(transaction)
        
        transactions.append(transaction)
        recalculateTotals()
    }
    func updateTransaction(
        originalTransaction: Transaction,
        type: TransactionType,
        amount: Double,
        title: String,
        category: String,
        date: Date,
        note: String?
    ) {
        guard amount > 0 else { return }
        guard isValidCategory(type: type, category: category) else { return }

        // Update SwiftData entity
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.id == originalTransaction.id }
        )

        guard let entity = try? context.fetch(descriptor).first else { return }

        entity.type = type.rawValue
        entity.amount = amount
        entity.title = title
        entity.category = category
        entity.date = date
        entity.note = note
        entity.isPending = true

        do {
            try context.save()
        } catch {
            print("Failed to update transaction:", error)
        }

        //  Update in-memory list (UI)
        if let index = transactions.firstIndex(where: { $0.id == originalTransaction.id }) {
            transactions[index] = Transaction(
                id: originalTransaction.id,
                userId: originalTransaction.userId,
                type: type,
                amount: amount,
                title: title,
                category: category,
                date: date,
                createdAt: originalTransaction.createdAt,
                note: note,
                isPending: true
            )
        }
        recalculateTotals()
    }

    
    func mapEntityToTransaction(_ entity : TransactionEntity)->Transaction{
        return Transaction(id: entity.id, userId: entity.userId, type: TransactionType(rawValue: entity.type) ?? .expense, amount: entity.amount,title: entity.title, category: entity.category, date: entity.date, createdAt: entity.createdAt,note: entity.note ,isPending: entity.isPending)
    }
    
    func loadTransactionsFromSwiftData(){
        guard let uid = Auth.auth().currentUser?.uid else {
            self.transactions = []
            recalculateTotals()
            return
        }
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate{entity in
                entity.userId == uid
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do{
            let entities = try context.fetch(descriptor)
            self.transactions = entities.map{mapEntityToTransaction($0)}
            recalculateTotals()
        }catch{
            print("Fail to load user transaction from swiftData \(error)")
            self.transactions = []
        }
    }
    
    func mapTransactionToEntity(_ transaction : Transaction) -> TransactionEntity{
        return TransactionEntity(
            id: transaction.id,
            userId: transaction.userId,
            type: transaction.type.rawValue,
            amount: transaction.amount,
            title: transaction.title,
            category: transaction.category,
            date: transaction.date,
            createdAt: transaction.createdAt,
            note: transaction.note,
            isPending: transaction.isPending
        )
    }
    
    func saveToSwiftData(_ transaction : Transaction){
        let entity = mapTransactionToEntity(transaction)
        context.insert(entity)
        
        do{
            try context.save()
        }catch{
            print("fail to save transaction to swiftData \(error)")
        }
    }
    
    func fetchPendingEntities() -> [TransactionEntity] {
        
        guard let uid = Auth.auth().currentUser?.uid else {
                return []
            }
        
        let descriptor = FetchDescriptor<TransactionEntity>(
                predicate: #Predicate {
                    $0.isPending == true && $0.userId == uid
                }
            )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch pending entities:", error)
            return []
        }
    }
    
    func makeFirestoreData(from entity: TransactionEntity) -> [String: Any] {
        [
            "id": entity.id,
            "userId": entity.userId,
            "type": entity.type,
            "amount": entity.amount,
            "title": entity.title,
            "category": entity.category,
            "date": Timestamp(date: entity.date),
            "createdAt": Timestamp(date: entity.createdAt),
            "note": entity.note ?? "",
            "isPending": false
        ]
    }
    
    func uploadToFirestore(
        entityId: String,
        userId: String,
        data: [String: Any]
    ) {
        db.collection("users")
            .document(userId)
            .collection("transactions")
            .document(entityId)
            .setData(data) { error in

                if let error = error {
                    print("Firestore upload failed:", error)
                    return
                }

                // back to MainActor safely
                Task { @MainActor in
                    self.markEntityAsSynced(entityId: entityId)
                }
            }
    }
    
    func markEntityAsSynced(entityId: String) {
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.id == entityId }
        )

        guard let entity = try? context.fetch(descriptor).first else {
            return
        }

        entity.isPending = false
        try? context.save()

        print("Entity marked as synced:", entityId)
    }

    func syncPendingTransactions() {
        let pendingEntities = fetchPendingEntities()

        guard !pendingEntities.isEmpty else {
            print("No pending transactions")
            return
        }

        print("Syncing \(pendingEntities.count) transactions")

        for entity in pendingEntities {
            let data = makeFirestoreData(from: entity)

            uploadToFirestore(
                entityId: entity.id,
                userId: entity.userId,
                data: data
            )
        }
    }
    
    // now this two function purpose is when user again install the app and login then there data will fetch from firestore
    
    func restoreFromFirestore(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        print("Restoring transactions from firestore ")
        
        
        db.collection("users")
            .document(uid)
            .collection("transactions")
            .getDocuments{ snapshot , error in
                if let error = error {
                    print("Firestore fetch failed:", error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No Firestore transactions found")
                    return
                }
                Task { @MainActor in
                    self.mergeFirestoreTransactions(documents)
                }

            }
    }
    
    // this is a purpose of this func : “Before inserting anything from Firestore, let me see what I already have locally.”
    
    private func mergeFirestoreTransactions(_ documents: [QueryDocumentSnapshot]) {

        // Fetch existing SwiftData IDs
        let descriptor = FetchDescriptor<TransactionEntity>()
        let existingEntities = (try? context.fetch(descriptor)) ?? []
        let existingIds = Set(existingEntities.map { $0.id })

        var newCount = 0

        // 2️⃣ Loop Firestore docs
        for doc in documents {

            let data = doc.data()

            let id = data["id"] as? String ?? doc.documentID

            //  Skip if already exists
            guard !existingIds.contains(id) else { continue }

            let entity = TransactionEntity(
                id: id,
                userId: data["userId"] as? String ?? "",
                type: data["type"] as? String ?? "expense",
                amount: data["amount"] as? Double ?? 0,
                title: data["title"] as? String ?? "",
                category: data["category"] as? String ?? "",
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                note: data["note"] as? String,
                isPending: false
            )

            context.insert(entity)
            newCount += 1
        }

        //  Save once
        do {
            try context.save()
            print("Restored \(newCount) transactions from Firestore")
            loadTransactionsFromSwiftData()
        } catch {
            print(" Failed saving restored transactions:", error)
        }
    }
}

