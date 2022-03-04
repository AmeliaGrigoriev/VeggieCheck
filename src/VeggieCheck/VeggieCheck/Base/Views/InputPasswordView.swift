//
//  InputPasswordView.swift
//  VeggieCheck
//
//  Created by Amelia Grigoriev on 20/02/2022.
//
// followed tutorial at: https://www.youtube.com/watch?v=5gIuYHn9nOc for firebase authentication

import SwiftUI

struct InputPasswordView: View {
    
    @Binding var password: String
    let placeholder: String
    let sfSymbol: String?
    
    private let textFieldLeading: CGFloat = 30
    
    var body: some View {
        
        SecureField(placeholder, text: $password)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.leading, sfSymbol == nil ? textFieldLeading / 2 : textFieldLeading)
            .background(
                
                ZStack(alignment: .leading) {
                    
                    if let systemImage = sfSymbol {
                        
                        Image(systemName: systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.leading, 5)
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.gray.opacity(0.25))
                }
            )
    }
}

struct InputPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        InputPasswordView(password: .constant(""),
                          placeholder: "Password",
                          sfSymbol: "lock")
            .preview(with: "Input Password with sfSymbol")
        
        InputPasswordView(password: .constant(""),
                          placeholder: "Password",
                          sfSymbol: nil)
            .preview(with: "Input Password without sfSymbol")
    }
}
