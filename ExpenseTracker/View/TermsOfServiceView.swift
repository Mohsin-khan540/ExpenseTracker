//
//  TermsOfServiceView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 03/01/2026.
//

import SwiftUI

struct TermsOfServiceView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Terms of Service")
                    .font(.title2)
                    .bold()

                Text("Last updated: January 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Group {
                    Text("Personal Use")
                        .font(.headline)

                    Text("""
ExpenseTracker is designed to help you track your daily expenses for personal use.
""")
                }

                Group {
                    Text("User Responsibility")
                        .font(.headline)

                    Text("""
The app displays expense information based on the data entered by the user.
""")
                }

                Group {
                    Text("No Financial Advice")
                        .font(.headline)

                    Text("""
ExpenseTracker does not provide financial or investment advice. It is intended for general expense tracking purposes.
""")
                }

                Group {
                    Text("App Availability")
                        .font(.headline)

                    Text("""
We aim to keep the app running smoothly. Occasional updates or temporary interruptions may occur.
""")
                }

                Group {
                    Text("Changes to These Terms")
                        .font(.headline)

                    Text("""
These Terms of Service may be updated as the app evolves and new features are added.
""")
                }

            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TermsOfServiceView()
}
