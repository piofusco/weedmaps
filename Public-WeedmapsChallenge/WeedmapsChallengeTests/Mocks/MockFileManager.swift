//
// Created by jarvis on 1/11/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

@testable import WeedmapsChallenge

class MockFileManager: WeedmapsFileManager {
    var nextURLS: [URL] = []

    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        nextURLS
    }
}
