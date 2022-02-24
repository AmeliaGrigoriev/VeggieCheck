//
//  ForgotPasswordView.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 16) {
                
                InputTextFieldView(text: .constant(""), placeholder: "Email", keyboardType: .emailAddress, sfSymbol: "envelope")
                
                ButtonView(title: "Send Password Reset") {
                    // TODO: password reset
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Reset Password")
            .applyClose()
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
