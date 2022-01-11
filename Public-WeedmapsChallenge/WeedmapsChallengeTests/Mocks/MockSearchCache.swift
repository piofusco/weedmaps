//
// Created by jarvis on 1/11/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

@testable import WeedmapsChallenge

class MockSearchCache: SearchCache {
    var didWrite = false
    var lastWrite: [String]?

    func write(_ previousSearches: [String]) {
        didWrite = true
        lastWrite = previousSearches
    }

    var didRead = false
    var nextPreviousSearches = [String]()

    func readPreviousSearches() -> [String] {
        didRead = true

        return nextPreviousSearches
    }
}
