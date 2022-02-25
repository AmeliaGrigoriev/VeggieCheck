//
//  CheckedView.swift
//  veggietest
//
//  Created by Róisín O’Rourke on 20/02/2022.
//

import SwiftUI

struct CheckedView: View {
    
    @ObservedObject var recognizedContent: RecognizedContent
    
    var body: some View {
        List(recognizedContent.items, id: \.id) { textItem in
            VStack {
                Text(String(textItem.vegan))
                Text(String(textItem.text))
            }
            
        }
    }
}

struct CheckedView_Previews: PreviewProvider {
    static var previews: some View {
        CheckedView(recognizedContent: RecognizedContent())
    }
}
