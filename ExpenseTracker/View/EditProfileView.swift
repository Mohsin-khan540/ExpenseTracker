//
//  EditProfileView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 17/01/2026.
//
import SwiftData
import SwiftUI

struct EditProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileVM: ProfileViewModel

    @State private var username: String
    
    var isUsernameValid: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var usernameField: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Username")
                .font(.footnote)
                .foregroundColor(.secondary)

            TextField("Enter username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)

            if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Username is required")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    init(profileVM: ProfileViewModel) {
        self.profileVM = profileVM
        _username = State(initialValue: profileVM.username)
    }

    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 20) {
                    usernameField

                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profileVM.updateProfileInfo(
                            username: username
                        )
                        dismiss()
                    }
                 .disabled(!isUsernameValid || username == profileVM.username)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = #"^\+[1-9]\d{7,14}$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            .evaluate(with: phone)
    }
}


#Preview {
    let container = try! ModelContainer(
        for: ProfileImageEntity.self
    )
    
    let context = container.mainContext
    let profileVM = ProfileViewModel(context: context)

     NavigationStack {
        EditProfileView(profileVM: profileVM)
    }
}
