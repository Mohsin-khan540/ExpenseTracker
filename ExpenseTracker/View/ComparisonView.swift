//
//  ComparisonView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 20/12/2025.
//

import SwiftUI
import Charts

struct ComparisonBar: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}
struct ComparisonView: View {
    
    @AppStorage(AppSettings.showDecimalPercentageKey)
    private var showDecimalPercentage = false
    
    @ObservedObject var transactionViewModel : TransactionViewModel
    
    var hasAnyExpenses: Bool {
        comparison.current > 0 || comparison.previous > 0
    }
    
    var comparison: (
        current: Double,
        previous: Double,
        difference: Double,
        percentage: Double?
    ) {
        transactionViewModel.monthlyExpenseComparison()
    }

    
    var barData : [ComparisonBar] {
        [
        ComparisonBar(
            month: transactionViewModel.reportMonth
                .formatted(.dateTime.month(.wide)),
            amount: comparison.current
        ),
        ComparisonBar(
            month: transactionViewModel.previousMonth(from: transactionViewModel.reportMonth)
                .formatted(.dateTime.month(.wide)),
            amount: comparison.previous
        )
        ]
    }
    
    var body: some View {
        NavigationStack{
            ScrollView{
                
                    HStack {
                        Button {
                            transactionViewModel.goToPreviousMonth()
                        } label: {
                            Image(systemName: "chevron.left")
                        }

                        Text(transactionViewModel.reportMonthTitle)
                            .font(.headline)

                        Button {
                            transactionViewModel.goToNextMonth()
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                if hasAnyExpenses{
                    VStack(spacing : 20){
                        
                        // top balance card
                        VStack(spacing: 12) {
                            
                            Text("You spent")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text(CurrencyFormatter.format(comparison.current))
                                .font(.system(size: 34, weight: .bold))
                            
                            if let percentage = comparison.percentage {
                                
                                let isIncrease = comparison.difference > 0
                                HStack(spacing: 6) {
                                    Image(systemName: isIncrease ? "arrow.up" : "arrow.down")
                                    
                                    let formattedPercentage: String = {
                                        if showDecimalPercentage{
                                            return String(format: "%.2f", abs(percentage))
                                        } else {
                                            return "\(Int(abs(percentage).rounded()))"
                                        }
                                    }()
                                    
                                    Text(
                                        "\(formattedPercentage)% " +
                                        (isIncrease ? "more" : "less") +
                                        " than last month"
                                    )
                                }
                                .font(.subheadline)
                                .foregroundStyle(isIncrease ? .red : .green)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.background)
                                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
                        )
                        
                        VStack(alignment: .leading, spacing : 12){
                            Text("Details")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            HStack{
                                VStack(alignment: .leading, spacing : 6){
                                    Text("This Month")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Text(CurrencyFormatter.format(comparison.current))
                                        .font(.headline)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing : 6){
                                    Text("Last Month")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Text(CurrencyFormatter.format(comparison.previous))
                                        .font(.headline)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                            )
                        }
                        .padding()
                        VStack(alignment: .leading, spacing : 12){
                            Text("Comparison")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Chart(barData){item in
                                BarMark(
                                    x : .value("Month" , item.month),
                                    y: .value("amount" , item.amount)
                                )
                                .cornerRadius(6)
                            }
                            .frame(height: 160)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.background)
                                .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                        )
                    }
                }else{
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("No expenses to compare")
                            .font(.headline)

                        Text("Add expenses to see monthly comparison.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .padding()

                }
            }
            .navigationTitle("Comparison")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ComparisonView(transactionViewModel: PreviewHelpers.transactionViewModel)
}
