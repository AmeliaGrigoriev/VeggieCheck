//
//  APItest.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 01/02/2022.
//

import Foundation

struct Checker: Codable {
    var isVeganSafe: Bool
}

class API {
    func getResults() {
        guard let url = URL(string: "https://is-vegan.netlify.com/.netlify/functions/api?ingredients=adrenaline,albumen") else {
            print("ingredients not entered correctly"); return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let results = try! JSONDecoder().decode(Checker.self, from: data!)
            print(results)
        }.resume()
    }
}

// completion: @escaping (Result<[Checker],Error>) -> Void
