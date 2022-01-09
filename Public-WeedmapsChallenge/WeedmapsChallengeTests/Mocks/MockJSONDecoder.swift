//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation
@testable import WeedmapsChallenge

class MockJSONDecoder<T: Decodable>: WeedmapsJSONDecoder {
    var nextDecodable: T?

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        guard let nextDecodable = nextDecodable as? T else {
            fatalError("Next decodable not set")
        }

        return nextDecodable
    }
}
