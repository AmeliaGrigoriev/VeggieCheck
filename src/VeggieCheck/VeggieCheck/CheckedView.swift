//
//  CheckedView.swift
//  veggietest
//
//  Created by Róisín O’Rourke on 20/02/2022.
//

import SwiftUI

struct CheckedView: View {
    
    @ObservedObject var recognizedContent: RecognizedContent
    @State var email: String
    @Environment(\.managedObjectContext) var managedObjectContext
//    @EnvironmentObject var sessionService: SessionServiceImpl
    
    var body: some View {
        VStack() {
            Text("recent searches")
                .onAppear {
                    print("working")
                    let search = UserSearches(context: managedObjectContext)
                    search.email = email
                    search.ingredients = String(recognizedContent.items.last?.text ?? "help")
                    search.vegan = recognizedContent.items.last?.vegan ?? false
        
                    PersistenceController.shared.save()
                    print(PersistenceController.shared.fetchSearches(with: email) ?? "no searches yet")
                }
            List(recognizedContent.items, id: \.id) { textItem in
                VStack {
                    Text(String(textItem.vegan))
                    Text(String(textItem.text))
                }
                
            }
        }
    }
}

struct CheckedView_Previews: PreviewProvider {
    static var previews: some View {
        CheckedView(recognizedContent: RecognizedContent(), email: "")
//            .environmentObject(SessionServiceImpl())
    }
}
