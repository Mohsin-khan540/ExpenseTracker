//
//  RootView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 18/12/2025.
//

import SwiftUI
import SwiftData

struct RootView: View {

    @StateObject private var authVM = AuthViewModel()
    @Environment(\.modelContext) private var context

    var body: some View {
        Group {
            if authVM.user != nil {
                MainTabView(
                    transactionViewModel: TransactionViewModel(context: context)
                )
                .environmentObject(authVM)
            } else {
                ContentView()
                    .environmentObject(authVM)
            }
        }
    }
}

#Preview {
    RootView()
}
