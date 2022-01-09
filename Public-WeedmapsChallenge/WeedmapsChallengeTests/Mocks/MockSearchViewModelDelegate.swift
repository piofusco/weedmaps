//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

@testable import WeedmapsChallenge

class MockSearchViewModelDelegate: SearchViewModelDelegate {
    var didCallSearchBusinesses = false

    var lastSuccess: Bool?

    func searchDidFinish(success: Bool) {
        lastSuccess = success

        didCallSearchBusinesses = true
    }
}
