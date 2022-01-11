//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

class AutoCompleteTableViewControllerTests: XCTestCase {
    func test__displayPreviousSearches__tableViewDataSourceIsPreviousSearches() {
        let mockAutoCompleteDelegate = MockAutoCompleteDelegate()
        let subject = AutoCompleteTableViewController()
        subject.delegate = mockAutoCompleteDelegate
        subject.previousSearches = ["previous search 1", "previous search 2"]
        subject.autoCompleteStrings = ["autocomplete 1"]
        subject.displayPreviousSearches = true

        subject.tableView(UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(mockAutoCompleteDelegate.lastSelectedTerm, "previous search 1")
        XCTAssertEqual(subject.tableView(UITableView(), numberOfRowsInSection: 0), 2)
    }

    func test__didSelectRowAt__tableViewDataSourceIsAutoComplete() {
        let mockAutoCompleteDelegate = MockAutoCompleteDelegate()
        let subject = AutoCompleteTableViewController()
        subject.delegate = mockAutoCompleteDelegate
        subject.previousSearches = ["previous search 1", "previous search 2"]
        subject.autoCompleteStrings = ["autocomplete 1"]
        subject.displayPreviousSearches = false

        subject.tableView(UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(mockAutoCompleteDelegate.lastSelectedTerm, "autocomplete 1")
        XCTAssertEqual(subject.tableView(UITableView(), numberOfRowsInSection: 0), 1)
    }
}