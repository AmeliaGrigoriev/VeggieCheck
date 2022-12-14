//
//  TextRecognition.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 25/01/2022.
//  base code from following tutorial at https://www.appcoda.com/swiftui-text-recognition/

import SwiftUI
import Vision

struct TextRecognition {
    var scannedImages: [UIImage]
    @ObservedObject var searches: Searches
    
    var didFinishRecognition: () -> Void
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var networkChecker = NetworkChecker()

    func recognizeText() {
        let queue = DispatchQueue(label: "textRecognitionQueue", qos: .userInitiated)
        queue.async {
            for image in scannedImages { // for each picture that has been taken in the one go
                guard let cgImage = image.cgImage else { return }
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
                do {
                    let searchItem = SearchItem()
                    try requestHandler.perform([getTextRecognitionRequest(with: searchItem)])
                    
                    DispatchQueue.main.async {
                        searches.items.append(searchItem)
                        print(createString(ingredients: searchItem.text))

                        if (networkChecker.isConnected) { // check if the user is connected to the internet
                            // create a string for the URL and pass to the API function
                            API().getResults(ingredients: createString(ingredients: searchItem.text)) { Checker in
                                if Checker.isVeganSafe {
                                    print("vegan safe")
                                    searchItem.vegan = true
                                }
                            }
                        }
                        else {
                            let ingredientList = createList(ingredients: searchItem.text) // turn the text captured into a list
                            var check = false
                            for ingredient in ingredientList { // go through the list
                                if !(PersistenceController.shared.fetchIngredient(with: ingredient)) {
                                    check = true // if ingredient was found -> non vegan
                                    break
                                }
                            }
                            if (check) {
                                print("NOT VEGAN")
                                searchItem.vegan = false // if ingredient was found -> non vegan
                            } else {
                                searchItem.vegan = true
                            }
                        }
                    }

                } catch {
                    print(error.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    
                    didFinishRecognition()
                }
            }
        }
    }
    
    private func getTextRecognitionRequest(with searchItem: SearchItem) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // create array of the text observed
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            observations.forEach { observation in // each line is an observation
                guard let recognizedText = observation.topCandidates(1).first else { return }
                // top candidates 1 -> the most accurate version of the text
                searchItem.text += recognizedText.string // add to the string of ingredients
                searchItem.text += " " // add a space to represent the new line break
            }
        }
        
        request.recognitionLevel = .accurate // get the most accurate results
        request.usesLanguageCorrection = true
        
        return request
    }
    
    // function to turn the ingredient string into a string that can be used for the API
    func createString(ingredients: String) -> String {
        let bannedWords = ["may contain", "traces of", "from", "contains"] // words that might prevent accurate results
        
        var lowerIngredients = ingredients.lowercased()
        // make the punctuation consistent
        lowerIngredients = lowerIngredients.replacingOccurrences(of: "[(:;.]", with: ",", options: .regularExpression)
        lowerIngredients = lowerIngredients.replacingOccurrences(of: ",,", with: ",")
        for word in bannedWords { // remove the banned words
            lowerIngredients = lowerIngredients.replacingOccurrences(of: word, with: "")
        }
        lowerIngredients = lowerIngredients.filter("abcdefghijklmnopqrstuvwxyz, ".contains)
        lowerIngredients = lowerIngredients.replacingOccurrences(of: ",,", with: ",")
        lowerIngredients = lowerIngredients.replacingOccurrences(of: ",,", with: ",")
        // get rid of all characters except letters and comma to seperate the words
        var APIstring = lowerIngredients.replacingOccurrences(of: " ", with: "%20") // spaces for URL

        let lastchar = APIstring.last!
        
        if (lastchar == "." || lastchar == ",") {
            APIstring.remove(at: APIstring.index(before: APIstring.endIndex))
        } // remove the last character if necessary
        return APIstring
    }
    
    // function to turn the ingredient string into an array to ccompare with db
    func createList(ingredients: String) -> [String] {
        let bannedWords = ["may contain", "traces of", "from", "contains"]
        
        var lowerIngredients = ingredients.lowercased()
        
        lowerIngredients = lowerIngredients.replacingOccurrences(of: "[(:;.]", with: ",", options: .regularExpression)
        for word in bannedWords {
            lowerIngredients = lowerIngredients.replacingOccurrences(of: word, with: "")
        }
        var stringToArray = lowerIngredients.filter("abcdefghijklmnopqrstuvwxyz, ".contains)

        let lastchar = stringToArray.last!
        
        if (lastchar == "." || lastchar == ",") {
            stringToArray.remove(at: stringToArray.index(before: stringToArray.endIndex))
        }
        // similar to function above but split the string on the commas
        let tempIngredientList = stringToArray.components(separatedBy: ",")
        // remove whitespaces on either side of the words
        let ingredientList = tempIngredientList.map { $0.trimmingCharacters(in: .whitespaces) }
        
        return ingredientList
    }
}
