//
//  WeedmapsChallengeUITests.swift
//  WeedmapsChallengeUITests
//
//  Created by Mark Anderson on 10/5/18.
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import XCTest

class WeedmapsChallengeUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testTabBarTitleLabelsExist() {
        let app = XCUIApplication()

        addUIInterruptionMonitor(withDescription: "Location Dialog") { (alert) -> Bool in
            alert.buttons["Allow While Using App"].tap()
            return true
        }
        app.tap()

        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Burgers")

        let autoCompleteTableView = app.tables.firstMatch
        XCTAssertTrue(autoCompleteTableView.cells.count > 0)

        let autoCompleteCell = autoCompleteTableView.cells.staticTexts["Burgers"]
        autoCompleteCell.tap()

        XCTAssertTrue(app.collectionViews.firstMatch.exists)
        let resultsCollectionViewTable = app.collectionViews.firstMatch
        resultsCollectionViewTable.cells.firstMatch.waitForExistence(timeout: 5.0)
        XCTAssertTrue(resultsCollectionViewTable.cells.count > 0)

        searchField.clearText()
        XCTAssertTrue(app.staticTexts["Burgers"].exists)
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()
        typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count))
    }
}
