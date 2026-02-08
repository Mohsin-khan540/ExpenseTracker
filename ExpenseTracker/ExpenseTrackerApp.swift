//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 17/12/2025.
//

import SwiftData
import Firebase
import SwiftUI

@main
struct ExpenseTrackerApp: App {
    init() {
            FirebaseApp.configure()
        }
    @AppStorage(AppSettings.appThemeKey)
    private var appTheme : AppTheme = .system
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appTheme.colorScheme)
        }
        .modelContainer(
            for: [
                TransactionEntity.self,
                ProfileImageEntity.self
            ]
        )

    }
}
