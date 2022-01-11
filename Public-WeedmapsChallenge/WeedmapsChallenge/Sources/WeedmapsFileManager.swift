//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol WeedmapsFileManager {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
}

extension FileManager: WeedmapsFileManager {}