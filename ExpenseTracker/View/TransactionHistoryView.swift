//
//  TransactionHistoryView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 28/12/2025.
//

import SwiftUI

struct TransactionHistoryView: View {
    @ObservedObject var transactionViewModel : TransactionViewModel
    @State private var selctedTransaction : Transaction?
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach(transactionViewModel.transactions){transaction in
                    let style = transaction.type == .income
                    ? ("arrow.down.circle.fill" , Color.green) :
                    styleForCategory(transaction.category)
                    
                    TransactionRow(
                        icon: style.0,
                        iconColor: style.1,
                        title: transaction.title,
                        category: transaction.category,
                        date: formattedDate(transaction.date),
                        amount: transaction.amount,
                        isIncome: transaction.type == .income
                    )
                    .onTapGesture{
                        selctedTransaction  = transaction
                    }
                }
            }
            .sheet(item: $selctedTransaction) { transaction in
                AddTransactionSheet(
                    transactionViewModel: transactionViewModel,
                    editingTransactions: transaction
                )
            }

            .navigationTitle("Transaction History")
        }
    }
    func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    func styleForCategory(_ category: String) -> (icon: String, color: Color) {
            switch category.lowercased() {
            case "food": return ("cart.fill", .blue)
            case "transport": return ("bus.fill", .purple)
            case "shopping": return ("bag.fill", .orange)
            case "entertainment": return ("film.fill", .pink)
            case "bills": return ("doc.text.fill", .red)
            case "rent": return ("house.fill", .brown)
            case "groceries": return ("cart.badge.plus", .green)
            case "health": return ("heart.fill", .red)
            case "education": return ("book.fill", .indigo)
            case "travel": return ("airplane", .cyan)
            case "utilities": return ("bolt.fill", .yellow)
            case "savings": return ("banknote.fill", .mint)
            case "others": return ("ellipsis.circle.fill", .gray)
            default: return ("questionmark.circle", .gray)
            }
        }
}

#Preview {
    TransactionHistoryView(transactionViewModel: PreviewHelpers.transactionViewModel)
}
