//
//  Model.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 25/01/2022.
//  based on tutorial at https://www.appcoda.com/swiftui-text-recognition/

import Foundation

class SearchItem: Identifiable {
    var id: String
    var text: String = ""
    var vegan: Bool = false
    
    init() {
        id = UUID().uuidString
    }
}


class Searches: ObservableObject {
    @Published var items = [SearchItem]()
}
