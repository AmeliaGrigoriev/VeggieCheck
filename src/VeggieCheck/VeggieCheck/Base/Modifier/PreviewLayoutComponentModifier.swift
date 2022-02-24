//
//  PreviewLayoutComponentModifier.swift
//  VeggieCheck
//
//  Created by Amelia Grigoriev on 24/02/2022.
//

import SwiftUI

struct PreviewLayourComponentModifier: ViewModifier {
    
    let name: String
    
    func body(content: Content) -> some View {
        
        content
            .previewLayout(.sizeThatFits)
            .previewDisplayName(name)
            .padding()
    }
}

extension View {
    
    func preview(with name: String) -> some View {
        self.modifier(PreviewLayourComponentModifier(name: name))
    }
}
