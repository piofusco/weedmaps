//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

class AutoCompleteTableViewControllerTests: XCTestCase {
    func test__didSelectRowAt__willCallDelegate() {
        let mockAutoCompleteDelegate = MockAutoCompleteDelegate()
        let subject = AutoCompleteTableViewController()
        subject.delegate = mockAutoCompleteDelegate
        subject.autoCompleteStrings = ["this one"]

        subject.tableView(UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(mockAutoCompleteDelegate.lastSelectedTerm, "this one")
    }

    func test__UISearchResultsUpdating__updateSearchResults__willCallDelegate() {
        let mockAutoCompleteDelegate = MockAutoCompleteDelegate()
        let subject = AutoCompleteTableViewController()
        subject.delegate = mockAutoCompleteDelegate
        let stubSearchController = UISearchController()
        stubSearchController.searchBar.text = "this text?"

        subject.updateSearchResults(for: stubSearchController)

        XCTAssertEqual(mockAutoCompleteDelegate.lastSearchedTerm, "this text?")
    }

    func test__UISearchBarDelegate__searchBarSearchButtonClicked__willCallDelegate() {
        let mockAutoCompleteDelegate = MockAutoCompleteDelegate()
        let subject = AutoCompleteTableViewController()
        subject.delegate = mockAutoCompleteDelegate
        let stubSearchBar = UISearchBar()
        stubSearchBar.text = "this text?"

        subject.searchBarSearchButtonClicked(stubSearchBar)

        XCTAssertEqual(mockAutoCompleteDelegate.lastSelectedTerm, "this text?")
    }
}