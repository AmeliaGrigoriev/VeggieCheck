//
//  CloseModifier.swift
//  VeggieCheckTesting
//
//  Created by Amelia Grigoriev on 20/02/2022.
//
// followed tutorial at: https://www.youtube.com/watch?v=5gIuYHn9nOc for firebase authentication

import SwiftUI

struct CloseModifier: ViewModifier {
    
//    presentation mode for screen do pop up
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        
        content
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // dismissing the pop up when close button is closed
                }, label: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                })
            }
    }
}

extension View {
    
    func applyClose() -> some View {
        self.modifier(CloseModifier())
    }
}
