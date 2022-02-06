//
//  Model.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 25/01/2022.
//

import Foundation

class TextItem: Identifiable {
    var id: String
    var text: String = ""
    
    init() {
        id = UUID().uuidString
    }
}


class RecognizedContent: ObservableObject {
    @Published var items = [TextItem]()
}
