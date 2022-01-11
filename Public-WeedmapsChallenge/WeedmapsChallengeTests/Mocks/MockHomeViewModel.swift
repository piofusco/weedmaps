//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

@testable import WeedmapsChallenge

class MockHomeViewModel: HomeViewModel {
    var delegate: HomeViewModelDelegate?

    var nextBusinesses: [Business]?
    var businesses: [Business] {
        get {
            nextBusinesses!
        }
    }

    var nextImageData: [Data?]?
    var imageCache: [Data?] {
        get {
            nextImageData!
        }
    }

    func search(term: String) {
        delegate?.didSearch()
    }

    var didLoadNextPage = false

    func loadNextPageOfBusinesses() {
        didLoadNextPage = true

        delegate?.didSearch()
    }

    var imageURLStrings = [String]()
    var imageIndices = [Int]()

    func fetchImageData(index: Int, urlString: String) {
        imageIndices.append(index)
        imageURLStrings.append(urlString)

        delegate?.didFetchImage(for: index, data: "".data(using: .utf8)!)
    }

    var nextAutoCompleteResponse: AutoCompleteResponse?
    var autoCompleteResponse: AutoCompleteResponse? {
        get {
            nextAutoCompleteResponse!
        }
    }

    func autoComplete(term: String) {

    }


}
