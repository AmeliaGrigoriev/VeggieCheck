//
//  TextRecognition.swift
//  VeggieCheck
//
//  Created by Róisín O’Rourke on 25/01/2022.
//

import SwiftUI
import Vision

struct TextRecognition {
    var scannedImages: [UIImage]
    @ObservedObject var recognizedContent: RecognizedContent
    
    var didFinishRecognition: () -> Void
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var networkChecker = NetworkChecker()

    func recognizeText() {
        let queue = DispatchQueue(label: "textRecognitionQueue", qos: .userInitiated)
        queue.async {
            for image in scannedImages {
                guard let cgImage = image.cgImage else { return }
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
                do {
                    let textItem = TextItem()
                    try requestHandler.perform([getTextRecognitionRequest(with: textItem)])
                    
                    DispatchQueue.main.async {
                        recognizedContent.items.append(textItem)
                        print(createString(ingredients: textItem.text))

                        if (networkChecker.isConnected) {
                            API().getResults(ingredients: createString(ingredients: textItem.text)) { Checker in
                                if Checker.isVeganSafe {
                                    print("vegan safe")
                                    textItem.vegan = true
                                }
                            }
                        }
                        else {
                            let help = createList(ingredients: textItem.text)
                            var check = false
                            for ingredient in help {
                                if !(PersistenceController.shared.fetchIngredient(with: ingredient)) {
                                    check = true
                                    break
                                }
                            }
                            if (check) {
                                print("NOT VEGAN")
                                textItem.vegan = false
                            } else {
                                textItem.vegan = true
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
    
    
    private func getTextRecognitionRequest(with textItem: TextItem) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            observations.forEach { observation in
                guard let recognizedText = observation.topCandidates(1).first else { return }
                textItem.text += recognizedText.string
                textItem.text += " "
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        return request
    }
    
    func createString(ingredients: String) -> String {
        let bannedWords = ["may contain", "traces of", "from", "contains"]
        
        var lowerIngredients = ingredients.lowercased()
        
        lowerIngredients = lowerIngredients.replacingOccurrences(of: "[(:;.]", with: ",", options: .regularExpression)
        for word in bannedWords {
            lowerIngredients = lowerIngredients.replacingOccurrences(of: word, with: "")
        }
        lowerIngredients = lowerIngredients.filter("abcdefghijklmnopqrstuvwxyz, ".contains)
        var APIstring = lowerIngredients.replacingOccurrences(of: " ", with: "%20")

        let lastchar = APIstring.last!
        
        if (lastchar == "." || lastchar == ",") {
            APIstring.remove(at: APIstring.index(before: APIstring.endIndex))
        }
        return APIstring
    }
    
    func createList(ingredients: String) -> [String] {
        let bannedWords = ["may contain", "traces of", "from", "contains"]
        
        var lowerIngredients = ingredients.lowercased()
        
        lowerIngredients = lowerIngredients.replacingOccurrences(of: "[(:;.]", with: ",", options: .regularExpression)
        for word in bannedWords {
            lowerIngredients = lowerIngredients.replacingOccurrences(of: word, with: "")
        }
        lowerIngredients = lowerIngredients.filter("abcdefghijklmnopqrstuvwxyz, ".contains)
        var stringToArray = lowerIngredients.replacingOccurrences(of: " ", with: "%20")

        let lastchar = stringToArray.last!
        
        if (lastchar == "." || lastchar == ",") {
            stringToArray.remove(at: stringToArray.index(before: stringToArray.endIndex))
        }
        
        let tempIngredientList = stringToArray.components(separatedBy: ",")
        
        let ingredientList = tempIngredientList.map { $0.trimmingCharacters(in: .whitespaces) }
        
        return ingredientList
    }
}
