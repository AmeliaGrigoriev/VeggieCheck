//
//  SearchesView.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 28/02/2022.
//

import SwiftUI

struct SearchesView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var email: String

    var prevsearches: [UserSearches] {
        return PersistenceController.shared.fetchSearches(with: email) ?? []
    } // fetch the previous searches for the current user
    
    var body: some View {
        VStack() {
            Text("Scan History")
                .font(.title)
                .fontWeight(.semibold)
            List { // list to show the previous searches
                ForEach(prevsearches, id:\.self) { search in
                    VStack(alignment: .leading, spacing: 10) {
                        if search.vegan { // if product searched was vegan
                            Text("Vegan Friendly")
                                .fontWeight(.semibold)
                                .foregroundColor(Color.green)
                        }
                        else {
                            Text("Not Vegan Friendly")
                                .fontWeight(.semibold)
                                .foregroundColor(Color.red)
                        }
                        
                        Text(search.ingredients ?? "could not find") // print the ingredients if present
                    }
                }
            }
        }
    }
}

struct SearchesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchesView(email: "")
    }
}
