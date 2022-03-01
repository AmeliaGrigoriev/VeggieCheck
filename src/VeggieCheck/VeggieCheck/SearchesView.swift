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
//    @State private var email: String = "hello@gmail.com"
//    var prevsearches: [UserSearches] = []
//    var prevsearches: [UserSearches] = PersistenceController.shared.fetchSearches(with: "Test05@test.com") ?? []
//    init(email: String) {
//        self.prevsearches = PersistenceController.shared.fetchSearches(with: email) ?? []
//    }
    var prevsearches: [UserSearches] {
        return PersistenceController.shared.fetchSearches(with: email) ?? []
    }
    
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        VStack() {
            Text("Scan History")
                .font(.title)
                .fontWeight(.semibold)
            List {
                ForEach(prevsearches, id:\.self) { i in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(String(i.vegan) )")
                            .fontWeight(.semibold)
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
