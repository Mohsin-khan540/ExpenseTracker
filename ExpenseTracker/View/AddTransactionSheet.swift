//
//  AddTransactionSheet.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 24/12/2025.
//

import SwiftUI

struct AddTransactionSheet: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var transactionViewModel : TransactionViewModel
    let editingTransactions : Transaction?
    init(transactionViewModel : TransactionViewModel, editingTransactions : Transaction? = nil){
        self.transactionViewModel = transactionViewModel
        self.editingTransactions = editingTransactions
    }
    
    @State private var title: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var amount: String = ""
    @State private var selectedCategory: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    var isFormValid : Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {return false}
        guard let amountValue = Double(trimmedAmount),
                amountValue > 0 else {return false}
        
        guard !selectedCategory.isEmpty else {return false}
        
        return true
        
    }

    var body: some View {
        NavigationStack {
            Form {

                Picker("Type", selection: $selectedType) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)

                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Title")) {
                    TextField(
                        selectedType == .expense
                        ? "Enter Expense name"
                        : "Enetr source of income",
                        text: $title
                    )
                }


                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $selectedCategory) {
                        if selectedType == .expense {
                            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                Text(category.rawValue.capitalized)
                                    .tag(category.rawValue)
                            }
                        } else {
                            ForEach(IncomeCategory.allCases, id: \.self) { category in
                                Text(category.rawValue.capitalized)
                                    .tag(category.rawValue)
                            }
                        }
                    }
                }

                Section(header: Text("Date")) {
                    DatePicker(
                        "Select date",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                }

                Section(header: Text("Note (Optional)")) {
                    TextField("Add note", text: $note)
                }
            }
            .onAppear{
                guard let transaction = editingTransactions else { return }
                title = transaction.title
                selectedType = transaction.type
                amount = String(transaction.amount)
                selectedCategory = transaction.category
                date = transaction.date
                note = transaction.note ?? ""
            }
            .navigationTitle(
                editingTransactions == nil ? "Add transactions" : "Edit transaction"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingTransactions == nil ? "Save" : "Update") {
                        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cleanedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)

                        guard let amountValue = Double(cleanedAmount) else { return }
                        if let transaction = editingTransactions {
                            transactionViewModel.updateTransaction(
                                originalTransaction: transaction,
                                type: selectedType,
                                amount: amountValue,
                                title: cleanedTitle,
                                category: selectedCategory,
                                date: date,
                                note: note.isEmpty ? nil : note
                            )
                        }else{
                               transactionViewModel.addTransaction(
                                type: selectedType,
                                amount: amountValue,
                                title: cleanedTitle,
                                category: selectedCategory,
                                date: date,
                                note: note.isEmpty ? nil : note
                            )
                        }
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

#Preview {
    AddTransactionSheet(transactionViewModel: PreviewHelpers.transactionViewModel)
}
