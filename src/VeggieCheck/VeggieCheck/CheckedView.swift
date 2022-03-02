//
//  CheckedView.swift
//  veggietest
//
//  Created by Róisín O’Rourke on 20/02/2022.
//

import SwiftUI

struct CheckedView: View { // view to see the most recent scanned item
    
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
                    if recognizedContent.items.count != 0 { // if there is a search to save
                        let search = UserSearches(context: managedObjectContext)
                        search.email = email // the current user's email address
                        search.ingredients = String(recognizedContent.items.last?.text ?? "help")
                        search.vegan = recognizedContent.items.last?.vegan ?? false
            
                        PersistenceController.shared.save() // save to the database
                        let findcount = PersistenceController.shared.fetchSearches(with: email) // fetch the searches
                        let count = findcount?.count // find how many items are in the db
                        print(count!)
                        if count! > 20 { // if over 20, delete the oldest searcj
                            PersistenceController.shared.deleteFirst(with: email)
                        }
                        
                        print(PersistenceController.shared.fetchSearches(with: email) ?? "no scans yet")
                    }
                }

            if recognizedContent.items.count != 0 { // if there is a search to display
                if recognizedContent.items.last?.vegan ?? false { // if item is vegan friendly
                    Text("Product Scanned is Vegan Friendly") // inform user
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
                Text("Ingredients: ") // prepare to list the ingredients scanned
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
