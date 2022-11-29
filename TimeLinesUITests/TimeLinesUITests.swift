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
    
    override func setUp() async throws {
//        bindCacheWithContacts(2)
        IAPManager.shared.hasAlreadyPurchasedUnlimitedContacts = true
    }
    
    override func tearDown() {
        print("Contacts: \(contacts.count)")
        for contact in contacts {
            if let contact = contact {
                CoreDataManager.shared.deleteContact(contact)
            }
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("Contacts: \(contacts.count)")
        for contact in contacts {
            if let contact = contact {
                CoreDataManager.shared.deleteContact(contact)
            }
        }
    }
    
    func oldTestAddingContact() throws {
        let addButtonPredicate = NSPredicate(format: "label beginswith 'Add a new contact'")
        app.buttons.element(matching: addButtonPredicate).tap()
    }
    
    func oldTestAddingContactNonPurchasedApp() throws {
        let addButtonPredicate = NSPredicate(format: "label beginswith 'Add a new contact'")
        app.buttons.element(matching: addButtonPredicate).tap()
        let unlockFullVersion = NSPredicate(format: "label beginswith 'Unlock Full Version'")
        XCTAssert(app.alerts.buttons.element(matching: unlockFullVersion).exists)
    }
    
    func oldTestAddingContactPurchasedApp() throws {
        let addButtonPredicate = NSPredicate(format: "label beginswith 'Add a new contact'")
        app.buttons.element(matching: addButtonPredicate).tap()
        let unlockFullVersion = NSPredicate(format: "label beginswith 'Unlock Full Version'")
        XCTAssert(app.alerts.buttons.element(matching: unlockFullVersion).exists)
    }
    
    // Create contact and delete it (should tap)
    func testCreatingNewContactAfterDeleting() throws {
//        let addButtonPredicate = NSPredicate(format: "label beginswith 'Add a new contact'")
        let addNewContactElement = app.buttons["Add a new contact"]
//        app.buttons.element(matching: addButtonPredicate).tap()
        addNewContactElement.tap()
        
        let nameInputField = app.textFields["Jane Doe"]
        nameInputField.tap()
        nameInputField.typeText("Test User")
        
        let locationInputField = app.buttons["San Francisco"]
        locationInputField.tap()
        let searchBar = app.searchFields["Search for a place"]
        searchBar.tap()
        searchBar.typeText("San Francisco")
        app.cells["San Francisco, CA"].tap()
        app.navigationBars.buttons["Done"].tap()
//        wait(for: [expectation(description: "Add a new contact")], timeout: 1)
        sleep(3)
//        waitForExpectations(timeout: 3) { [weak self] _ in
//            guard let self = self else { return }
        let unlockFullVersion = NSPredicate(format: "name LIKE 'Test User'")
        print(app.cells.element(matching: unlockFullVersion).exists)
        print("Number of cells: ", app.cells.count)
        for cellRow in app.cells.allElementsBoundByAccessibilityElement {
            print(cellRow)
        }
//        XCTAssert(app.cells.element(matching: unlockFullVersion).exists)
//        }
//        XCTAssert(app.cells["Test User"].exists)
    }
    
    // TEST CREATING NEW CONTACT -> DELETING AND TAPPING ON BUTTON
    
    //    func testExample() throws {
    //        // UI tests must launch the application that they test.
    //        let app = XCUIApplication()
    //        app.launch()
    //
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //    }
    
    //    func testLaunchPerformance() throws {
    //        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
    //            // This measures how long it takes to launch your application.
    //            measure(metrics: [XCTApplicationLaunchMetric()]) {
    //                XCUIApplication().launch()
    //            }
    //        }
    //    }
    
    func bindCacheWithContacts(_ numberOfContacts: Int) {
        for i in 1...numberOfContacts {
            let name = "Test Name\(i)"
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
