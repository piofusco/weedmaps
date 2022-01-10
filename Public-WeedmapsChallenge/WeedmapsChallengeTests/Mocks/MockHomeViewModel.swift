//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

@testable import WeedmapsChallenge

class MockHomeViewModel: HomeViewModel {
    var delegate: SearchViewModelDelegate?

    var nextBusinesses: [Business]?
    var businesses: [Business] {
        get {
            nextBusinesses!
        }
    }

    var nextImageData: [Data?]?
    var imageData: [Data?] {
        get {
            nextImageData!
        }
    }

    func search(term: String) {
    }

    func loadNextPageOfBusinesses() {
    }

    var imageURLStrings = [String]()
    var imageIndices = [Int]()

    func fetchImageData(index: Int, urlString: String) {
        imageIndices.append(index)
        imageURLStrings.append(urlString)
    }
}
