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
    func getResults(ingredients: String, completion: @escaping (Checker) -> ()) {
        let fullURL = "https://is-vegan.netlify.com/.netlify/functions/api?ingredients=" + ingredients
        print(fullURL)
        guard let url = URL(string: fullURL) else {
            print("ingredients not entered correctly"); return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let results = try! JSONDecoder().decode(Checker.self, from: data!)
//            print(results)
            DispatchQueue.main.async {
                completion(results)
            }
        }.resume()
    }
}

