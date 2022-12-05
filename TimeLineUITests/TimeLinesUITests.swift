//
//  TimeLinesUITests.swift
//  TimeLinesUITests
//
//  Created by Matej Ballo on 27/11/2022.
//  Copyright © 2022 Mathieu Dutour. All rights reserved.
//

import XCTest
import TimeLineShared

final class TimeLinesUITests: XCTestCase {
    let app = XCUIApplication()
    var contacts: [Contact?] = [Contact?]()
    private let userName = "Test User"
    private let location = "San Francisco, CA"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws { }
    
    // 1. Test editing myself
    func test01EditOnlyMe() {
        let lastCell = app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1)
        XCTAssert(!app.navigationBars.buttons["Edit"].exists && lastCell.staticTexts["Me"].exists)
    }
    
    // 2. Test creating new contact
    func test02CreateNewContact() throws {
        createNewContact(userName: userName, location: location)
        app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1).tap()
        XCTAssert(app.staticTexts[userName].exists && app.staticTexts[location].exists)
    }
    
    // 3. Test editing existing contact
    func test03EditContact() throws {
        let updatedLocation = "Košice"
        app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1).tap()
        app.buttons["Edit"].tap()
        app.buttons[location].tap()
        let searchBar = app.searchFields["Search for a place"]
        searchBar.tap()
        searchBar.typeText(updatedLocation)
        app.cells[updatedLocation].tap()
        app.navigationBars.buttons["Done"].tap()
        app.navigationBars.buttons["Contacts"].tap()
        app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1).tap()
        XCTAssert(app.staticTexts[userName].exists && app.staticTexts[updatedLocation].exists)
    }
    
    // 4. Test deleting new contact
    func test04DeleteContact() throws {
        app.navigationBars.buttons["Edit"].forceTap()
        let cellToDelete = app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1)
        cellToDelete.buttons.element(boundBy: 0).tap()
        cellToDelete.buttons["Delete"].tap()
        
        let rowExist = app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1).staticTexts[userName].exists
        XCTAssert(!rowExist)
    }
    
    // 5. Test adding contact to non purchased app with measuring time of creating contact
    func test05AddingContactNonPurchasedApp() throws {
        let options = XCTMeasureOptions()
        options.iterationCount = 2
        measure(options: options) {
            createNewContact(userName: userName, location: location)
        }
        app.buttons["Add a new contact"].tap()
        XCTAssert(app.alerts.buttons["Unlock Full Version"].exists)
    }

    // 6. Opening Add new contact dialog after deleting all contacts
    func test06AddingContactAfterDeletingLast() {
        app.navigationBars.buttons["Edit"].forceTap()
        let contactsNumber = CoreDataManager.shared.fetch().count
        for _ in 1...contactsNumber {
            let cellToDelete = app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1)
            cellToDelete.buttons.element(boundBy: 0).tap()
            cellToDelete.buttons["Delete"].tap()
        }
        app.buttons["Add a new contact"].tap()
        XCTAssert(app.staticTexts["New Contact"].exists)
    }
    
    // Zakomentuj
    func test07MeasureMemory() {
        self.measure(metrics: [XCTMemoryMetric(), XCTStorageMetric()]) {
            app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1).tap()
            sleep(4)
            app.navigationBars.buttons["Contacts"].tap()
        }
    }
    

}
