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
// After editing contact add button is disabled

final class TimeLinesTests: XCTestCase {
    typealias CDM = CoreDataManager

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
        CDM.shared.createTag(name: "TestTag", color: .yellow)
        let result = CoreDataManager.shared.findTag("TestTag")
        XCTAssertEqual(result?.color, .green)
    }
    
    func testEditingCreatedContact() throws {
        
    }
    
    func testDeleteNewContacts() throws {
        
    }

}
