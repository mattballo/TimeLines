//
//  TimeLinesUITestsExtension.swift
//  TimeLinesUITests
//
//  Created by Matej Ballo on 05/12/2022.
//  Copyright © 2022 Mathieu Dutour. All rights reserved.
//

import XCTest
import TimeLineShared

extension TimeLinesUITests {

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

        sleep(2)
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

extension XCUIElement {
    func forceTap() {
        coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5)).tap()
    }
}
