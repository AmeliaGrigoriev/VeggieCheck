//
//  VeggieCheckTests.swift
//  VeggieCheckTests
//
//  Created by Róisín O’Rourke on 01/03/2022.
//

import XCTest
@testable import VeggieCheck
import Vision

class MockTextRecognition {
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
    
    func getTextRecognitionRequest(with textItem: TextItem) -> VNRecognizeTextRequest {
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
                textItem.text += recognizedText.string // add to the string of ingredients
                textItem.text += " " // add a space to represent the new line break
            }
        }
        
        request.recognitionLevel = .accurate // get the most accurate results
        request.usesLanguageCorrection = true
        
        return request
    }
}

class VeggieCheckTests: XCTestCase {

    func testAPI() {
        let ingredient = "sugar"
        var search: Checker?
        let call = API()
        let expectation = self.expectation(description: "API Call complete")
        call.getResults(ingredients: ingredient) { Checker in
            search = Checker
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNotNil(search)
        XCTAssert(search!.isVeganSafe)
    }
    
    func testAPIAgainstDB() {
        let ingredient = "sugar"
        var search: Checker?
        let call = API()
        let expectation = self.expectation(description: "API Call complete")
        call.getResults(ingredients: ingredient) { Checker in
            search = Checker
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        let foods: [String] = VeggieCheckApp().addIngredients()
        var isVegan = true
//        if foods.contains(ingredient) {
//            isVegan = false
//        }
        for food in foods {
            if food == ingredient {
                isVegan = false
                break
            }
        }
        
        var same = false
        if search!.isVeganSafe == isVegan {
            same = true
        }
//        XCTAssert(search!.isVeganSafe)
//        XCTAssert(isVegan)
        XCTAssertTrue(same)
    }

    func testIngredientsToURLString() {
        let actualList = "eggs, milk, sugar "
        let URLString = MockTextRecognition().createString(ingredients: actualList)
        var URLworking = true
        guard URL(string: URLString) != nil else {
            print("ingredients not entered correctly")
            URLworking = false
            XCTAssertTrue(URLworking)
            return
        }
        
        XCTAssertTrue(URLworking)
    }

    func testTextRecognitionAccuracy() {
        let imageForTesting = UIImage(named: "testScan")!
        guard let cgImage = imageForTesting.cgImage else { return }
        let recognisedList = TextItem()
        var actualList = "eggs, milk, sugar "
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([MockTextRecognition().getTextRecognitionRequest(with: recognisedList)])
            print(recognisedList)
        }
        catch {
            print(error.localizedDescription)
        }
        actualList = actualList.replacingOccurrences(of: " ", with: "")
        recognisedList.text = recognisedList.text.replacingOccurrences(of: " ", with: "")
        XCTAssertEqual(recognisedList.text, actualList)
    }
    
    func testPerformanceRecognition() throws {
        let imageForTesting = UIImage(named: "image1")!
        guard let cgImage = imageForTesting.cgImage else { return }
        let recognisedList = TextItem()
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([MockTextRecognition().getTextRecognitionRequest(with: recognisedList)])
                print(recognisedList)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func testPerformanceAPI() throws {
        var ingredient = "sugar, wheat, milk, eggs, butter, whey, salt, albumen, water"
        ingredient = MockTextRecognition().createString(ingredients: ingredient)
        var search: Checker?
        let call = API()
        
        measure {
            let expectation = self.expectation(description: "API Call complete")
            call.getResults(ingredients: ingredient) { Checker in
                search = Checker
                
                expectation.fulfill()
            }
            waitForExpectations(timeout: 10, handler: nil)
            XCTAssertNotNil(search)
        }
    }
}

