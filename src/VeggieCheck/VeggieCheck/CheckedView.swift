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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Most Recent Scan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .onAppear {
                    print("working")
                    if recognizedContent.items.count != 0 {
                        let search = UserSearches(context: managedObjectContext)
                        search.email = email
                        search.ingredients = String(recognizedContent.items.last?.text ?? "help")
                        search.vegan = recognizedContent.items.last?.vegan ?? false
            
                        PersistenceController.shared.save()
                        print(PersistenceController.shared.fetchSearches(with: email) ?? "no scans yet")
                    }
                }

            if recognizedContent.items.count != 0 {
                if recognizedContent.items.last?.vegan ?? false {
                    Text("Product Scanned is Vegan Friendly")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.green)
                }
                else {
                    Text("Product Scanned is not Vegan Friendly")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.red)
                }
                Spacer()
                Text("Ingredients: ")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
//            Spacer()
            Text(String(recognizedContent.items.last?.text ?? "no scans to show yet"))
            Spacer()
        }
    }
}

struct CheckedView_Previews: PreviewProvider {
    static var previews: some View {
        CheckedView(recognizedContent: RecognizedContent(), email: "")
    }
}
