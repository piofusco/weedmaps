//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation
@testable import WeedmapsChallenge

class MockJSONEncoder<T: Encodable>: WeedmapsJSONEncoder {
    var nextData: Data?
    var didEncode = false

    func encode<T>(_ value: T) throws -> Data where T: Encodable {
        didEncode = true

        guard let nextData = nextData else {
            fatalError("Next data not set")
        }

        return nextData
    }
}
