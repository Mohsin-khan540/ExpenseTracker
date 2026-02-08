//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 17/12/2025.
//

import SwiftUI

struct LabeledIconField<Content: View>: View {
    let label: String
    let icon: String
    let content: Content

    init(label: String, icon: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            IconField(icon: icon) {
                content
            }
        }
    }
}


struct IconField<Content: View>: View {
    let icon: String
    let content: Content

    init(icon: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)

            content
        }
        .formFieldStyle()
    }
}




struct FormFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
            )
            .foregroundStyle(.primary)
    }
}

extension View{
    func formFieldStyle() -> some View{
        self.modifier(FormFieldModifier())
    }
}

struct ContentView: View {
    
    @EnvironmentObject var AuthVM : AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var isLogin = true
    
    
    @State private var userName = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            ScrollView{
                VStack(spacing : 15){
                    VStack(spacing : 12){
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                        if isLogin {
                            Text("Welcome Back")
                                .font(.system(.title2).weight(.semibold))

                            Text("Track your expenses smartly")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        } else {
                            Text("Create Account")
                                .font(.system(.title2).weight(.semibold))

                            Text("Start tracking your expenses today")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }

                    }
                    VStack(spacing : 5){
                        if !isLogin{
                            LabeledIconField(label: "Username", icon: "person"){
                                TextField("Enter username" , text: $userName)
                                    .onChange(of: userName) {
                                        AuthVM.errorMessage = nil
                                    }
                            }

                        }
                        
                        LabeledIconField(label: "Email", icon: "envelope") {
                            TextField("Enter email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .onChange(of: email) {
                                    AuthVM.errorMessage = nil
                                }
                        }

                        
                        LabeledIconField(label: "Password", icon: "lock"){
                            HStack {
                                if showPassword {
                                    TextField("Enter password", text: $password)
                                } else {
                                    SecureField("Enter password", text: $password)
                                        .onChange(of: password) {
                                            AuthVM.errorMessage = nil
                                        }
                                }

                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        if isLogin {
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    // dummy for now
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if !isLogin{
                            LabeledIconField(label: "confirm Password", icon: "lock"){
                                HStack {
                                    if showConfirmPassword {
                                        TextField("confirm password", text: $confirmPassword)
                                    } else {
                                        SecureField("confirm  password", text: $confirmPassword)
                                            .onChange(of: confirmPassword) {
                                                AuthVM.errorMessage = nil
                                            }
                                    }

                                    Button {
                                        showConfirmPassword.toggle()
                                    } label: {
                                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }


                        }
                    }
                    if let error = AuthVM.errorMessage{
                        Text(error)
                            .foregroundStyle(Color.red)
                            .font(.caption)
                    }
                    
                    
                    
                    Button(isLogin ? "Login" : "Signup"){
                        AuthVM.errorMessage = nil
                        
                        if isLogin{
                            guard !email.isEmpty, !password.isEmpty else {
                                AuthVM.errorMessage = "Email and password are required"
                                return
                            }
                            AuthVM.signIn(email: email, password: password)
                        }else{
                            
                            let trimmedusername = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            guard !trimmedusername.isEmpty else{
                                AuthVM.errorMessage = "username is required"
                                return
                            }
                            guard !email.isEmpty else {
                                AuthVM.errorMessage = "Email is required"
                                return
                            }
                            guard isValidEmail(email) else {
                                AuthVM.errorMessage = "Please enter a valid email address"
                                return
                            }
                            let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedPassword.isEmpty else {
                                AuthVM.errorMessage = "Password cannot be empty"
                                return
                            }
                            
                            guard trimmedPassword.count >= 6 else {
                                AuthVM.errorMessage = "Password must be at least 6 characters"
                                return
                            }
                            
                            
                            let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            guard trimmedPassword == trimmedConfirmPassword else {
                                AuthVM.errorMessage = "Passwords do not match"
                                return
                            }
                            
                            AuthVM.signUp(
                                email: email,
                                password: trimmedPassword,
                                username: trimmedusername,
//                                phoneNumber: cleanedPhone
                            )
                        }
                    }
                    .frame(width: 300 , height: 50)
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .cornerRadius(20)
                    Button(
                        isLogin
                        ? "Don't  have an account? Sign up"
                        : "Already have an account? Login"
                    ) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isLogin.toggle()
                            confirmPassword = ""
                        }
                    }

                }
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex)
            .evaluate(with: email)
    }

}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
