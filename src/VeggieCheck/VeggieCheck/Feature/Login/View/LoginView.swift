//
//  LoginView.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//
// followed tutorial at: https://www.youtube.com/watch?v=5gIuYHn9nOc for firebase authentication

import SwiftUI

struct LoginView: View {
    
    @State private var showRegistration = false
    @State private var showForgotPassword = false
        
    @StateObject private var vm = LoginViewModelImpl(
        service: LoginServiceImpl()
    )
    
    var body: some View {
            
            VStack(spacing: 16) {
                
                VStack(spacing: 16) {
                    // enter email text field
                    InputTextFieldView(text: $vm.credentials.email,
                                       placeholder: "Email",
                                       keyboardType: .emailAddress,
                                       sfSymbol: "envelope")
                    
                    // enter password text field
                    InputPasswordView(password: $vm.credentials.password,
                                      placeholder: "Password",
                                      sfSymbol: "lock")
                }
                
                HStack {
                    Spacer()
                    Button(action: { // forgot password button
                        showForgotPassword.toggle()
                    }, label: {
                        Text("Forgot Password?")
                            .foregroundColor(Color.green)
                    })
                    .font(.system(size: 16, weight: .bold))
                    .sheet(isPresented: $showForgotPassword) {
                            ForgotPasswordView()
                    }
                }
                
                VStack(spacing: 16) {
                    
                    ButtonView(title: "Login") {
                        vm.login()
                    }
                    
                    ButtonView(title: "Register",
                               background: .clear,
                               foreground: .green,
                               border: .green) {
                        showRegistration.toggle()
                    }
                    .sheet(isPresented: $showRegistration) {
                            RegisterView() // brings user to registration screen
                    }
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Login")
            .alert(isPresented: $vm.hasError, content: {
                // if login fails
                if case .failed(let error) = vm.state {
                    return Alert(
                        title: Text("Error"),
                        message: Text(error.localizedDescription))
                } else { // if there is no localized description
                    return Alert(
                        title: Text("Error"),
                        message: Text("Something went wrong"))
                }
            })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
    }
}
