//
//  ReportsView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 20/12/2025.
//

import SwiftUI
import Charts

struct ReportsView: View {
    
    @AppStorage(AppSettings.showDecimalPercentageKey)
    private var showDecimalPercentage = false

    @ObservedObject var transactionViewModel : TransactionViewModel
    var reportData: [CategoryReportItem] {
        transactionViewModel.expenseCategoryPercentagesForMonth()
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing : 20){
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

                    if reportData.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)

                            Text("No data available this month")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 40)
                    }else{
                        VStack(spacing: 8) {
                            Chart(reportData) { item in
                                SectorMark(
                                    angle: .value("Percentage", item.percentage),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 2
                                )
                                .foregroundStyle(colorForCategory(item.category))
                            }
                            .frame(height: 220)
                            .chartLegend(.hidden)
                            .animation(.easeInOut(duration: 0.6), value: reportData)

                            Text("Expense Distribution")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        VStack(spacing : 16){
                            ForEach(reportData) { item in
                                HStack {
                                    Circle()
                                        .fill(colorForCategory(item.category))
                                        .frame(width: 10, height: 10)
                                    
                                    Text(item.category)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    let formattedPercentage: String = {
                                        if showDecimalPercentage{
                                            return String(format: "%.2f", item.percentage)
                                        } else {
                                            return "\(Int(item.percentage.rounded()))"
                                        }
                                    }()

                                    Text("\(formattedPercentage)%")
                                        .foregroundStyle(.secondary)

                                }
                            }
                            
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    func colorForCategory(_ category : String) -> Color{
        switch category{
        case "Food": return .orange
        case "Transport": return .blue
        case "Shopping": return .purple
        case "Health": return .red
        case "Education": return .indigo
        case "Bills": return .green
        default: return .secondary
        }
    }
}

#Preview {
    ReportsView(transactionViewModel: PreviewHelpers.transactionViewModel)
}
