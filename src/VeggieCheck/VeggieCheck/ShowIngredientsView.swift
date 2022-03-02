//
//  ShowIngredientsView.swift
//  veggietest
//
//  Created by Róisín O’Rourke on 17/02/2022.
//

import SwiftUI

struct ShowIngredientsView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Vegan.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Vegan.ingredient, ascending: true)])
    var ingredients: FetchedResults<Vegan>
    
    var body: some View {
        VStack() {
            Text("Non Vegan Ingredients")
                .font(.title)
                .fontWeight(.semibold)
            List {
                ForEach(ingredients, id:\.self) { i in
                    Text("\(i.ingredient ?? "unknown")")
                }
            }
        }
        
    }
}

struct ShowIngredientsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowIngredientsView()
    }
}
