//
//  ChangePasswordView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 24/01/2026.
//

import SwiftUI


struct ChangePasswordView: View {

    @StateObject private var vm = ChangePasswordViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    SecureField("Current Password", text: $vm.currentPassword)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black , lineWidth: 1)
                    )

                SecureField("New Password", text: $vm.newPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)

                SecureField("Confirm New Password", text: $vm.confirmPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let success = vm.successMessage {
                    Text(success)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    vm.changePassword()
                } label: {
                    if vm.isLoading {
                        ProgressView()
                    } else {
                        Text("Change Password")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.isFormValid ? Color.blue : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!vm.isFormValid)
            }
            .padding()
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChangePasswordView()
}
