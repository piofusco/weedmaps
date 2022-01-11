//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol SearchCache {
    func write(_ previousSearches: [String])
    func readPreviousSearches() -> [String]
}

class WeedmapsSearchCache: SearchCache {
    private let fileManager: WeedmapsFileManager
    private let decoder: WeedmapsJSONDecoder
    private let encoder: WeedmapsJSONEncoder

    init(fileManager: WeedmapsFileManager, decoder: WeedmapsJSONDecoder, encoder: WeedmapsJSONEncoder) {
        self.fileManager = fileManager
        self.decoder = decoder
        self.encoder = encoder
    }

    func write(_ previousSearches: [String]) {
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to retrieve documents URL")
            return
        }
        let plistURL = documents.appendingPathComponent("searches.plist")

        do {
            let data = try encoder.encode(previousSearches)
            try data.write(to: plistURL)
        } catch {
            print(error)
        }
    }

    func readPreviousSearches() -> [String] {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to retrieve documents URL")
            return []
        }
        let plistURL = documentsPath.appendingPathComponent("searches.plist")

        var searches = [String]()
        do {
            let data = try Data(contentsOf: plistURL)
            searches = try decoder.decode([String].self, from: data)
        } catch {
            print(error)
        }

        return searches
    }
}