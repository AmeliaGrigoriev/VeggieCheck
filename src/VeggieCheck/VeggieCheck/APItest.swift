//
//  APItest.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 01/02/2022.
//

import Foundation

struct Checker: Codable { // struct to hold relevant returned JSON data
    var isVeganSafe: Bool
}

class API {
    // function to find out if ingredients are vegan friendly or not
    func getResults(ingredients: String, completion: @escaping (Checker) -> ()) {
        let fullURL = "https://is-vegan.netlify.com/.netlify/functions/api?ingredients=" + ingredients
        // add the ingredients passed in to the url
        print(fullURL)
        guard let url = URL(string: fullURL) else { // make sure url is working
            print("ingredients not entered correctly"); return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error { // if an error occurs return nothing
                print(error)
                return
            }
            // decode the JSON to the Checker struct
            let results = try! JSONDecoder().decode(Checker.self, from: data!)
//            print(results)
            DispatchQueue.main.async {
                completion(results)
            }
        }.resume()
    }
}

