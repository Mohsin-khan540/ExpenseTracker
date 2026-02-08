//
//  PrivacyPolicyView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 03/01/2026.
//

import SwiftUI

struct PrivacyPolicyView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Privacy Policy")
                    .font(.title2)
                    .bold()

                Text("Last updated: January 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Group {
                    Text("Overview")
                        .font(.headline)

                    Text("""
ExpenseTracker respects your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use the app.
""")
                }

                Group {
                    Text("Information We Collect")
                        .font(.headline)

                    Text("""
• Email address for authentication
• Expense data entered by you (amount, category, date)

We do not access your device contacts, location data, or payment information.

""")
                }

                Group {
                    Text("How We Use Your Information")
                        .font(.headline)

                    Text("""
Your information is used only to:
• Authenticate your account
• Store and display your expenses
• Improve app functionality
""")
                }

                Group {
                    Text("Data Storage & Security")
                        .font(.headline)

                    Text("""
Your data is securely stored using Firebase services. We apply standard security practices to protect your information.
""")
                }

                Group {
                    Text("Ads & Tracking")
                        .font(.headline)

                    Text("""
Currently, ExpenseTracker does not display ads and does not track users for advertising purposes.

This may change in future versions, and this policy will be updated accordingly.
""")
                }

                Group {
                    Text("Data Sharing")
                        .font(.headline)

                    Text("""
We do not sell, trade, or share your personal data with third parties.
""")
                }

                Group {
                    Text("Policy Updates")
                        .font(.headline)

                    Text("""
This Privacy Policy may be updated as new features are added. Continued use of the app means you accept any updates.
""")
                }

            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
        PrivacyPolicyView()

}
