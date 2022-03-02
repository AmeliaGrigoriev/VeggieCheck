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
    }
    
    var body: some View {
        VStack() {
            Text("Scan History")
                .font(.title)
                .fontWeight(.semibold)
            List {
                ForEach(prevsearches, id:\.self) { i in
                    VStack(alignment: .leading, spacing: 10) {
                        if i.vegan {
                            Text("Vegan Friendly")
                                .fontWeight(.semibold)
                                .foregroundColor(Color.green)
                        }
                        else {
                            Text("Not Vegan Friendly")
                                .fontWeight(.semibold)
                                .foregroundColor(Color.red)
                        }
                        
                        Text(i.ingredients ?? "could not find")
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
