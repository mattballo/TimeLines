//
//  TimeLinesTests.swift
//  TimeLinesTests
//
//  Created by Matej Ballo on 27/11/2022.
//  Copyright © 2022 Mathieu Dutour. All rights reserved.
//

import XCTest
import TimeLineShared

// 1. Ukladanie do cache
// 2. Mazanie z cache
// 3. Editovanie v cache
// 4. Načítanie z cache
// 5. Pridavanie viac ako 5 v neplatenej verzii
// 6. Pridavanie viac ako 5 v platenej verzii
// 7. Vytvaranie tagov a mazanie

final class TimeLinesTests: XCTestCase {
    override class func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSaveNewContact() throws {
        CoreDataManager.shared.createTag(name: "TestTag", color: .yellow)
        let result = CoreDataManager.shared.findTag("TestTag")
        XCTAssertEqual(result?.color, .green)
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
