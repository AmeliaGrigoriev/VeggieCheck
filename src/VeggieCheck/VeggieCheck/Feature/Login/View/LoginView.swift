//
//  LoginView.swift
//  VeggieCheck
//
//  Created by Amelia Grigoriev on 20/02/2022.
//

import SwiftUI

struct LoginView: View {
    
    @State private var showRegistration = false
    @State private var showForgotPassword = false
    
    var body: some View {
            
            VStack(spacing: 16) {
                
                VStack(spacing: 16) {
                    
                    InputTextFieldView(text: .constant(""),
                                       placeholder: "Email",
                                       keyboardType: .emailAddress,
                                       sfSymbol: "envelope")
                    
                    InputPasswordView(password: .constant(""),
                                      placeholder: "Password",
                                      sfSymbol: "lock")
                }
                
                HStack {
                    Spacer()
                    Button(action: {
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
                        // TODO: Handle login action here
                    }
                    
                    ButtonView(title: "Register",
                               background: .clear,
                               foreground: .green,
                               border: .green) {
                        showRegistration.toggle()
                    }
                    .sheet(isPresented: $showRegistration) {
                            RegisterView()
                    }
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Login")
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
