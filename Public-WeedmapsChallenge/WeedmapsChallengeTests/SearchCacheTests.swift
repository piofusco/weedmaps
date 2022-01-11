//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

class SearchCacheTests: XCTestCase {
    func test__read__whenDocumentURLIsNil__returnEmpty() {
        let subject = WeedmapsSearchCache(
                fileManager: MockFileManager(),
                decoder: MockJSONDecoder<[String]>(),
                encoder: MockJSONEncoder<Data>()
        )

        XCTAssertEqual(subject.readPreviousSearches(), [])
    }

    func test__write__whenDocumentURLIsNil__doNotEncode() {
        let mockJSONEncoder = MockJSONEncoder<Data>()
        let subject = WeedmapsSearchCache(
                fileManager: MockFileManager(),
                decoder: MockJSONDecoder<[String]>(),
                encoder: mockJSONEncoder
        )

        subject.write([])

        XCTAssertFalse(mockJSONEncoder.didEncode)
    }

    func test__write__willEncode() {
        let mockFileManager = MockFileManager()
        mockFileManager.nextURLS = [URL(string: "file://www.apple.com")!]
        let mockJSONEncoder = MockJSONEncoder<Data>()
        mockJSONEncoder.nextData = "".data(using: .utf8)!
        let subject = WeedmapsSearchCache(
                fileManager: mockFileManager,
                decoder: MockJSONDecoder<[String]>(),
                encoder: mockJSONEncoder
        )

        subject.write([])

        XCTAssertTrue(mockJSONEncoder.didEncode)
    }
}
