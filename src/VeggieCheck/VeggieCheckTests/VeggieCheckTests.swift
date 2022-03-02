//
//  VeggieCheckTests.swift
//  VeggieCheckTests
//
//  Created by Róisín O’Rourke on 01/03/2022.
//

import XCTest
@testable import VeggieCheck

class VeggieCheckTests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testanotherAPI() {
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
    
    func testAgainstDB() {
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
        
        XCTAssert(search!.isVeganSafe)
        XCTAssert(isVegan)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

