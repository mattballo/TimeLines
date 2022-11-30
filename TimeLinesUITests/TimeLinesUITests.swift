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
    
    override func setUp() {
        super.setUp()
//        bindCacheWithContacts(1)
    }
    
    override func tearDown() {
        for contact in contacts {
            if let contact = contact {
                CoreDataManager.shared.deleteContact(contact)
            }
        }
        super.tearDown()
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        for contact in contacts {
            if let contact = contact {
                CoreDataManager.shared.deleteContact(contact)
            }
        }
    }
    
    func testEditOnlyMe() {
        let lastCell = app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1)
        XCTAssert(!app.navigationBars.buttons["Edit"].exists && lastCell.staticTexts["Me"].exists)
    }
    
    func testCreateNewContact() throws {
        let userName = "Test User"
        let location = "San Francisco, CA"
        
        createNewContact(userName: userName, location: location)
        
        app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1).tap()
        XCTAssert(app.staticTexts[userName].exists && app.staticTexts[location].exists)
    }
    
    func testDeleteNewContact() throws {
        let userName = "User To Delete"
        createNewContact(userName: userName, location: "San Francisco, CA")
        
        app.navigationBars.buttons["Edit"].forceTapElement()
        
        let cellToDelete = app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1)
        cellToDelete.buttons.element(boundBy: 0).tap()
        cellToDelete.buttons["Delete"].tap()
        
        let rowExist = app.tables.element(boundBy: 0).cells.element(boundBy: app.cells.count-1).staticTexts[userName].exists
        XCTAssert(!rowExist)
    }
    
    func testDeleteContactAndCreateNew() throws {
        
    }
    
    func testAddingContactNonPurchasedApp() throws {
        bindCacheWithContacts(3)
        app.buttons["Add a new contact"].tap()
        XCTAssert(app.alerts.buttons["Unlock Full Version"].exists)
    }
    
    // TODO: MOVE TO EXTENSIONS
    
    func createNewContact(userName: String, location: String) {
        app.buttons["Add a new contact"].tap()
        
        let nameInputField = app.textFields["Jane Doe"]
        nameInputField.tap()
        nameInputField.typeText(userName)
        
        app.buttons["San Francisco"].tap()
        let searchBar = app.searchFields["Search for a place"]
        searchBar.tap()
        searchBar.typeText("San Francisco")
        
        app.cells[location].tap()
        app.navigationBars.buttons["Done"].tap()
        
        sleep(1)
    }
    
    func bindCacheWithContacts(_ numberOfContacts: Int) {
        for i in 1...numberOfContacts {
            let name = "Test Name(\(i))"
            let createdContact = CoreDataManager.shared.createContact(
                name: name,
                latitude: 0,
                longitude: 0,
                locationName: "",
                timezone: 0,
                startTime: nil,
                endTime: nil,
                tags: nil,
                favorite: false
            )
            contacts.append(createdContact)
        }
    }
}

// TODO: Test if non-purchased app allows you to create a new contact
// TODO: Test if editing show list of users and without "ME"

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVectorMake(0.0, 0.0))
            coordinate.tap()
        }
    }
}
