//
//  VeggieCheckTests.swift
//  VeggieCheckTests
//
//  Created by Róisín O’Rourke on 26/02/2022.
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
    
    func getTextRecognitionRequest(with searchItem: SearchItem) -> VNRecognizeTextRequest {
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
}

class VeggieCheckTests: XCTestCase {

    // test that the API returns the correct result
    func testAPI() {
        let ingredients = "sugar,wheat,milk,eggs,butter,whey,salt,albumen,water"
        var search: Checker?
        let call = API()
        let expectation = self.expectation(description: "API Call complete")
        call.getResults(ingredients: ingredients) { Checker in // pass ingredient list to API
            search = Checker
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNotNil(search)
        XCTAssertFalse(search!.isVeganSafe) // assert the result is as expected
    }
    
    // test that the Database will return the same results as the API
    func testAPIAgainstDB() {
        let ingredients = "sugar,wheat,milk,eggs,butter,whey,salt,albumen,water"
        // convert the ingredients into a list for the database to use
        let ingredientList = MockTextRecognition().createList(ingredients: ingredients)
        var search: Checker?
        let call = API()
        let expectation = self.expectation(description: "API Call complete")
        call.getResults(ingredients: ingredients) { Checker in
            search = Checker
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        let foods: [String] = VeggieCheckApp().addIngredients() // create an array to mock the db
        var isVegan = true
        // check if any of the ingredients are in the database
        for ingredient in ingredientList {
            if foods.contains(ingredient) {
                isVegan = false
                break
            }
        }
        
        var same = false
        if search!.isVeganSafe == isVegan { // check that both results are the same
            same = true
        }

        XCTAssertTrue(same)
    }

    // test the list of ingredients can be passed to the URL
    func testIngredientsToURLString() {
        let actualList = "eggs, milk, sugar "
        let URLString = MockTextRecognition().createString(ingredients: actualList)
        var URLworking = true
        guard URL(string: URLString) != nil else { // check if the string can be converted to a URL
            print("ingredients not entered correctly")
            URLworking = false
            XCTAssertTrue(URLworking)
            return
        }
        
        XCTAssertTrue(URLworking)
    }

    // test how accurate the text recognition is
    func testTextRecognitionAccuracy() {
        let imageForTesting = UIImage(named: "image1")! // select the image from the assets
        guard let cgImage = imageForTesting.cgImage else { return }
        let recognisedList = SearchItem()
        var actualList = "Wheat Flour (Wheat Flour, Calcium Carbonate, Iron, Niacin, Thiamin), 24% Seed Mix (Golden Linseeds, Brown Linseeds, Millet Seeds, Hemp Seeds), 8% Wholemeal Rye Flour, Rapeseed Oil, Salt."
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do { // run text recognition
            try requestHandler.perform([MockTextRecognition().getTextRecognitionRequest(with: recognisedList)])
        }
        catch {
            print(error.localizedDescription)
        }
        actualList = actualList.replacingOccurrences(of: " ", with: "") // text recognition can add spaces that dont effect the API
        recognisedList.text = recognisedList.text.replacingOccurrences(of: " ", with: "") // but will lead to wrong comparison
        XCTAssertEqual(recognisedList.text, actualList) // check theyre the same
    }
    
    // test how long the text recognition takes
    func testPerformanceRecognition() throws {
        let imageForTesting = UIImage(named: "image1")!
        guard let cgImage = imageForTesting.cgImage else { return }
        let recognisedList = SearchItem()
        
        measure { // runs the code ten times and finds average time
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
    
    // test how long the API takes
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

