//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 20/12/2025.
//

import SwiftUI
import FirebaseAuth

struct TransactionRow : View {
    let icon: String
    let iconColor: Color
    let title: String
    let category: String
    let date: String
    let amount: Double
    let isIncome: Bool
    
    var body: some View {
        HStack(spacing: 12){
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 36 , height: 36)
                .background(iconColor.opacity(0.15))
                .cornerRadius(10)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(category.capitalized) , \(date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
           Spacer()
            Text(CurrencyFormatter.format(amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isIncome ? .green : .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
}

struct DashboardView: View {
    
    @ObservedObject var transactionViewModel : TransactionViewModel
    @State private var isShowingAddTransactionSheet = false
    @State private var selctedTransaction : Transaction?
    // balance card
    var balanceCard : some View {
        VStack(spacing: 12) {

            HStack {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Text(transactionViewModel.selectedPeriod.title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))

                Spacer()

                Menu {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(period.rawValue) {
                            transactionViewModel.selectedPeriod = period
                            transactionViewModel.recalculateTotals()
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(transactionViewModel.selectedPeriod.rawValue)
                            .font(.caption)
                            .foregroundColor(.white)

                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }

            Text(CurrencyFormatter.format(transactionViewModel.balance))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue)
        )
        .padding(.horizontal)
    }
    var incomeExpenseCards : some View {
        HStack(spacing: 16){
            // for income
            VStack{
                Text("Income")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.format(transactionViewModel.totalIncome))
                HStack{
                    Text(transactionViewModel.selectedPeriod.title)
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.green)
                }
                    
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 6)
            )

            // for expense
            VStack{
                Text("Expenses")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.format(transactionViewModel.totalExpense))
                    .foregroundStyle(.red)
                HStack{
                    Text(transactionViewModel.selectedPeriod.title)
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 6)
            )

        }
        .padding()
    }
     var recentTransactions: some View {
        VStack(spacing: 12) {

            HStack {
                Text("Recent Expenses")
                    .font(.headline)

                Spacer()
                
                // move to history screen

                NavigationLink{
                    TransactionHistoryView(transactionViewModel: transactionViewModel)
                }label: {
                    Text("Veiw all")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(transactionViewModel.transactions.prefix(10)) { transaction in

                    let style = transaction.type == .income
                    ? ("arrow.down.circle.fill", Color.green)
                    : styleForCategory(transaction.category)

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
                        selctedTransaction = transaction
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }


    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing : 20){
                    balanceCard
                    incomeExpenseCards
                    recentTransactions
                    
                }
                .padding(.top)
            }
            .sheet(item: $selctedTransaction){transaction in
                AddTransactionSheet(transactionViewModel: transactionViewModel, editingTransactions: transaction)
            }
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.inline)
            
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button{
                            isShowingAddTransactionSheet = true
                        }label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading){
                       NavigationLink{
                            SettingsView()
                        }label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .onAppear{
                    transactionViewModel.loadTransactionsFromSwiftData()
                    
                    // Cloud sync only when user is logged in
                    
                        if Auth.auth().currentUser != nil {
                            transactionViewModel.syncPendingTransactions()
                            transactionViewModel.restoreFromFirestore()
                        }
                }
        }
        .sheet(isPresented: $isShowingAddTransactionSheet){
            AddTransactionSheet(
                transactionViewModel: transactionViewModel
            )
        }
    }
    
    func formattedDate(_ date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
   func styleForCategory(_ category: String) -> (icon: String, color: Color) {
        switch category.lowercased() {

        case "food":
            return ("cart.fill", .blue)

        case "transport":
            return ("bus.fill", .purple)

        case "shopping":
            return ("bag.fill", .orange)

        case "entertainment":
            return ("film.fill", .pink)

        case "bills":
            return ("doc.text.fill", .red)

        case "rent":
            return ("house.fill", .brown)

        case "groceries":
            return ("cart.badge.plus", .green)

        case "health":
            return ("heart.fill", .red)

        case "education":
            return ("book.fill", .indigo)

        case "travel":
            return ("airplane", .cyan)

        case "utilities":
            return ("bolt.fill", .yellow)

        case "savings":
            return ("banknote.fill", .mint)

        case "others":
            return ("ellipsis.circle.fill", .gray)

        default:
            return ("questionmark.circle", .gray)
        }
    }

}

#Preview {
    DashboardView(transactionViewModel: PreviewHelpers.transactionViewModel)
}
