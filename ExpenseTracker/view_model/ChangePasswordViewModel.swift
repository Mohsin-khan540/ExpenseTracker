//
//  ChangePasswordViewModel.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 24/01/2026.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class ChangePasswordViewModel: ObservableObject {

    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?


    var isFormValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword != currentPassword &&
        newPassword == confirmPassword &&
        !isLoading
    }

    func changePassword() {
        errorMessage = nil
        successMessage = nil

        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            errorMessage = "User not logged in."
            return
        }

        isLoading = true
        
        
        //It only verifies identity. check if this is really a user
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: currentPassword
        )

        //  Re-authenticate
        
        //[weak self] means ->Firebase, don’t keep this screen alive just for you. when you leave then self nil
        
        user.reauthenticate(with: credential) { [weak self] _, error in
            
            //If the screen is already gone, stop here. - > when user leave changepasswordview screen
            guard let self else { return }
            
            // if identify wrong like you give wrong current password
            if let error = error {
                self.isLoading = false
                self.errorMessage = self.mapAuthError(error)
                return
            }

            //  Update password
            user.updatePassword(to: self.newPassword) { error in
                self.isLoading = false
                
                 // may be network issue then show error
                if let error = error {
                    self.errorMessage = self.mapAuthError(error)
                    return
                }
                 // when update sucess
                self.clearFields()
                self.successMessage = "Password updated successfully."
            }
        }
    }

    private func clearFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
    
    //Firebase error codes live inside NSError

    private func mapAuthError(_ error: Error) -> String {
        let nsError = error as NSError

        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Current password is incorrect."
        case AuthErrorCode.weakPassword.rawValue:
            return "New password is too weak."
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return "Please log in again to change your password."
        default:
            return error.localizedDescription
        }
    }
}
