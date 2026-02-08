//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 02/01/2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.appThemeKey)
    private var appTheme: AppTheme = .system
    @AppStorage(AppSettings.showDecimalPercentageKey)
    private var showDecimalPercentage = false
    var body: some View {
        NavigationStack{
            List{
                Section("Appearance") {
                    NavigationLink {
                       ThemeSelectionView()
                    } label: {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)

                            Text("Theme")

                            Spacer()

                            Text(appTheme.title)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Preferences") {

                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.green)

                        VStack(alignment: .leading) {
                            Text("Currency")
                            Text("Based on your region")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(Locale.current.currency?.identifier ?? "—")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Image(systemName: "percent")
                            .foregroundStyle(.orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Percentage Precision")
                            Text("Show decimal values in comparison")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                       Toggle("" , isOn: $showDecimalPercentage)
                            .labelsHidden()
                    }
                }

                Section("About") {
                    HStack {
                        NavigationLink{
                            PrivacyPolicyView()
                        }label: {
                            Image(systemName: "shield.fill")
                                .foregroundStyle(.blue)

                            Text("Privacy Policy")
                        }
                    }

                    HStack {
                        NavigationLink{
                            TermsOfServiceView()
                        }label: {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.orange)

                            Text("Terms of Service")
                        }
                    }
                    HStack{
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.gray)
                        Text("App Version")
                        Spacer()
                        Text(AppInfo.version)
                    }
                    ShareLink(
                        item: "Check out this Expense Tracker app! Track your income and expenses easily.Coming soon on the App Store"
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundStyle(.blue)
                            Text("Share App")
                        }
                    }

                }

            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
