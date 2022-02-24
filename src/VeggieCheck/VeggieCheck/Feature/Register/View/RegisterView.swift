//
//  RegisterView.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject private var vm = RegistrationViewModelImpl(service: RegistrationServiceImpl())
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 32) {
                
                VStack(spacing: 16) {
                    
                    InputTextFieldView(text: $vm.userDetails.email,
                                       placeholder: "Email",
                                       keyboardType: .emailAddress,
                                       sfSymbol: "envelope")
                    
                    InputPasswordView(password: $vm.userDetails.password,
                                      placeholder: "Password",
                                      sfSymbol: "lock")
                    
                    Divider()
                    
                    InputTextFieldView(text: $vm.userDetails.firstName,
                                       placeholder: "First Name",
                                       keyboardType: .namePhonePad,
                                       sfSymbol: nil)
                    
                    InputTextFieldView(text: $vm.userDetails.lastName,
                                       placeholder: "Last Name",
                                       keyboardType: .namePhonePad,
                                       sfSymbol: nil)
            
                }
                
                ButtonView(title: "Sign Up") {
                    vm.register()
                }
            }
            .padding(.horizontal, 15)
            .navigationTitle("Register")
            .applyClose()
            .alert(isPresented: $vm.hasError, content: {
                
                if case .failed(let error) = vm.state {
                    return Alert(
                        title: Text("Error"),
                        message: Text(error.localizedDescription))
                } else {
                    return Alert(
                        title: Text("Error"),
                        message: Text("Something went wrong"))
                }
            })
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
