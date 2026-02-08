//
//  AuthViewModel.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 17/12/2025.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation
import Combine

class AuthViewModel : ObservableObject{
    
  @Published  var user : User?
  @Published  var errorMessage : String?
    
    private let db = Firestore.firestore()
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    func signUp(
        email: String,
        password: String,
        username: String
    ) {
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

           guard let user = result?.user else { return }
            let uid = user.uid
            
            // here i am storing extra user data in firestore
            
            let userData: [String: Any] = [
                "email": email,
                "username": username,
                "createdAt": Timestamp()
            ]

            self?.db.collection("users")
                .document(uid)
                .setData(userData) { error in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }

                    self?.user = user
                }

        }
    }
    
    func signIn(email : String ,password : String){
        errorMessage = nil
        Auth.auth().signIn(withEmail : email , password : password){ result , error in
            if let error = error{
                self.errorMessage = "incorrect password or email \(error.localizedDescription)"
                return
            }
            self.user = result?.user
        }
    }
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.user = nil
        }catch{
            self.errorMessage = error.localizedDescription
        }
    }

}
