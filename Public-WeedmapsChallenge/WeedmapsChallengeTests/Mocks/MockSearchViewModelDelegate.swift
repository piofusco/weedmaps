//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

@testable import WeedmapsChallenge

class MockSearchViewModelDelegate: HomeViewModelDelegate {
    var numberOfSearches = 0

    func didSearch() {
        numberOfSearches += 1
    }

    var searchDidFail = false
    var searchErrors = [YelpError]()

    func searchDidFail(with error: Error) {
        searchDidFail = true
        searchErrors.append(error as! YelpError)
    }

    var didFetchImage = false
    var fetchedImageRows = [Int]()
    var imageData = [Data]()

    func didFetchImage(for row: Int, data: Data) {
        didFetchImage = true
        fetchedImageRows.append(row)
        imageData.append(data)
    }

    var imageFetchDidFail = false
    var failedImageRows = [Int]()
    var imageFetchErrors = [YelpError]()

    func imageFetchFailed(for row: Int, with error: Error) {
        imageFetchDidFail = true
        failedImageRows.append(row)
        imageFetchErrors.append(error as! YelpError)
    }

    var didCallAutoComplete = false

    func didAutoComplete() {
        didCallAutoComplete = true
    }

    var didCallAutoCompleteDidFail = false
    var autoCompleteErrors = [YelpError]()

    func autoCompleteDidFail(with error: Error) {
        didCallAutoCompleteDidFail = true

        autoCompleteErrors.append(error as! YelpError)
    }
}
