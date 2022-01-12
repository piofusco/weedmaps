//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol SearchCache {
    func write(_ previousSearch: String)
    func readPreviousSearches() -> [String]
}

class WeedmapsSearchCache: SearchCache {
    private let fileManager: WeedmapsFileManager

    init(fileManager: WeedmapsFileManager) {
        self.fileManager = fileManager
    }

    func write(_ newSearch: String) {
        guard let pathToDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        let pathToPropertyList = pathToDocuments.appending("/searches.plist")

        if !FileManager.default.fileExists(atPath: pathToPropertyList) {
            if let bundle = Bundle.main.path(forResource: "searches", ofType: "plist") {
                do {
                    try FileManager.default.copyItem(atPath: bundle, toPath: pathToPropertyList)
                } catch {
                    print(error)
                }
            }
        }

        guard let dictionary = NSMutableDictionary(contentsOfFile: pathToPropertyList) else { return }

        if var previousSearches = dictionary["searches"] as? [String] {
            if !previousSearches.contains(newSearch) {
                previousSearches.append(newSearch)
                dictionary["searches"] = previousSearches
            }
        } else {
            dictionary["searches"] = [newSearch]
        }

        dictionary.write(toFile: pathToPropertyList, atomically: true)
    }

    func readPreviousSearches() -> [String] {
        guard let pathToDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return [] }
        let pathToPropertyList = pathToDocuments.appending("/searches.plist")

        if !FileManager.default.fileExists(atPath: pathToPropertyList) {
            if let bundle = Bundle.main.path(forResource: "searches", ofType: "plist") {
                do {
                    try FileManager.default.copyItem(atPath: bundle, toPath: pathToPropertyList)
                } catch {
                    print(error)
                }
            }
        }

        guard let dictionary = NSMutableDictionary(contentsOfFile: pathToPropertyList) else { return [] }
        guard let previousSearches = dictionary["searches"] as? [String] else { return [] }
        return previousSearches
    }
}