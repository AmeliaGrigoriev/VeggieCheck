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
                        API().getResults(ingredients: createString(ingredients: textItem.text))
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
//                textItem.text += "\n"
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        return request
    }
    
    func createString(ingredients: String) -> String {
//        var ingredients = textItem.text
        let lowerIngredients = ingredients.lowercased()
//        var wordToRemove = "contains"
        
        let halfway = lowerIngredients.replacingOccurrences(of: "[(:;]", with: ",", options: .regularExpression)
//        if let range = halfway.range(of: wordToRemove) {
//           halfway.removeSubrange(range)
//        }
        let another = halfway.replacingOccurrences(of: "from", with: "")
        let string1 = another.replacingOccurrences(of: "contains", with: "")
//        let onemore = string1.replacingOccurrences(of: " ", with: "%20")
//        let string2 = string1.replacingOccurrences(of: ", ", with: ",")
//        let string3 = string2.replacingOccurrences(of: " ,", with: ",")
        let plz = string1.filter("abcdefghijklmnopqrstuvwxyz, ".contains)
        var APIstring = plz.replacingOccurrences(of: " ", with: "%20")
//        var APIstring = onemore.replacingOccurrences(of: " ", with: "%20")
        // only works without spaces !!!!!! need to change
        
        let lastchar = APIstring.last!
        
        if (lastchar == "." || lastchar == ",") {
            APIstring.remove(at: APIstring.index(before: APIstring.endIndex))
        }
        return APIstring
    }
}
