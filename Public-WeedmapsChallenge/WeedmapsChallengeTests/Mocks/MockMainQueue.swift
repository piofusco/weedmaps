//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

@testable import WeedmapsChallenge

class MockMainQueue: MainQueue {
    var numberOfAsyncCalls = 0

    func async(_ work: @escaping @convention(block) () -> ()) {
        numberOfAsyncCalls += 1
    }
}