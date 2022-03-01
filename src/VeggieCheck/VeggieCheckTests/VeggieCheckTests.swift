//
//  VeggieCheckTests.swift
//  VeggieCheckTests
//
//  Created by Róisín O’Rourke on 01/03/2022.
//

import XCTest

class VeggieCheckTests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testAPI() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        struct Checker: Codable {
            var isVeganSafe: Bool
//            var nonvegan: [String]
        }

        class API {
            func getResults(ingredients: String, completion: @escaping (Checker) -> ()) {
                let fullURL = "https://is-vegan.netlify.com/.netlify/functions/api?ingredients=" + ingredients
                guard let url = URL(string: fullURL) else {
                    print("ingredients not entered correctly"); return
                }
                
                URLSession.shared.dataTask(with: url) { (data, _, _) in
                    let results = try! JSONDecoder().decode(Checker.self, from: data!)
                    completion(results)
                }.resume()
            }
        }
        
        API().getResults(ingredients: "chicken") { Checker in
            print(Checker.isVeganSafe)
            XCTAssertEqual(Checker.isVeganSafe, false)
//            XCTAssertEqual(Checker.nonvegan, ["chicken"])
        }
        
    }
    
    func testAPIAgainstNonVeganList() throws {

        struct Checker: Codable {
            var isVeganSafe: Bool
//            var nonvegan: [String]
        }

        class API {
            func getResults(ingredients: String, completion: @escaping (Checker) -> ()) {
                let fullURL = "https://is-vegan.netlify.com/.netlify/functions/api?ingredients=" + ingredients
                guard let url = URL(string: fullURL) else {
                    print("ingredients not entered correctly"); return
                }
                
                URLSession.shared.dataTask(with: url) { (data, _, _) in
                    let results = try! JSONDecoder().decode(Checker.self, from: data!)
                    completion(results)
                }.resume()
            }
            
            func addIngredients() -> [String] {
                
                var myStrings: [String] = []

                if let path = Bundle.main.path(forResource: "nonveganlist", ofType: "txt") {
                    do {
                        let data = try String(contentsOfFile: path, encoding: .utf8)
                        let lowerIngredients = data.lowercased()
                        myStrings = lowerIngredients.components(separatedBy: .newlines)
                    } catch {
                        print(error)
                    }
                }
                return myStrings
            }
            
            func checkInDB(ingredient: String) -> Bool {
                var isVegan: Bool = true
                let dbIngredients: [String] = addIngredients()
                
                if (dbIngredients.contains(ingredient)) {
                    isVegan = false
                }
                
                return isVegan
            }
        }
        
        API().getResults(ingredients: "tallow") { Checker in
            XCTAssertEqual(Checker.isVeganSafe, API().checkInDB(ingredient: "tallow"))
//            XCTAssertEqual(Checker.nonvegan, ["albumen"])
        }
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
