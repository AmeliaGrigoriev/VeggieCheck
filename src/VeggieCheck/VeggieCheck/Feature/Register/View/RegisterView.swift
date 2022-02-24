//
//  RegisterView.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//

import SwiftUI

struct RegisterView: View {
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 32) {
                
                VStack(spacing: 16) {
                    
                    InputTextFieldView(text: .constant(""),
                                       placeholder: "Email",
                                       keyboardType: .emailAddress,
                                       sfSymbol: "envelope")
                    
                    InputPasswordView(password: .constant(""),
                                      placeholder: "Password",
                                      sfSymbol: "lock")
                    
                    Divider()
                    
                    InputTextFieldView(text: .constant(""),
                                       placeholder: "First Name",
                                       keyboardType: .namePhonePad,
                                       sfSymbol: nil)
                    
                    InputTextFieldView(text: .constant(""),
                                       placeholder: "Last Name",
                                       keyboardType: .namePhonePad,
                                       sfSymbol: nil)
            
                }
                
                ButtonView(title: "Sign Up") {
                    // TODO: Handle create action here
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Register")
            .applyClose()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
