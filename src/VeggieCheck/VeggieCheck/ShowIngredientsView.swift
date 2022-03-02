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
    var ingredients: FetchedResults<Vegan> // fetch all the non vegan ingredients
    
    var body: some View {
        VStack() {
            Text("Non Vegan Ingredients")
                .font(.title)
                .fontWeight(.semibold)
            List { // create a list to show all the ingredients
                ForEach(ingredients, id:\.self) { item in
                    Text("\(item.ingredient ?? "unknown")")
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
