//
//  MainTabView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 20/12/2025.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    let transactionViewModel : TransactionViewModel
    @Environment(\.modelContext) private var context
    var body: some View {
        TabView {
            DashboardView(transactionViewModel: transactionViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            ReportsView(transactionViewModel: transactionViewModel)
                .tabItem {
                    Label("Reports", systemImage: "chart.pie.fill")
                }

            ComparisonView(transactionViewModel: transactionViewModel)
                .tabItem {
                    Label("Comparison", systemImage: "chart.bar.fill")
                }

            ProfileView(context: context)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
                   
    }
}

#Preview {
   MainTabView(transactionViewModel: PreviewHelpers.transactionViewModel)
}
