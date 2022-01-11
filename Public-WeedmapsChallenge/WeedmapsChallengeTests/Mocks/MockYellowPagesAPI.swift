//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//
import CoreLocation

@testable import WeedmapsChallenge

class MockYellowPagesAPI: YellowPagesAPI {
    var didSearch = false
    var lastSearchTerm: String?
    var lastSearchLocation: CLLocation?
    var lastOffset: Int?
    var nextPageResults: [Result<PageResponse, Error>] = []

    func search(term: String, location: CLLocation, offset: Int, completion: @escaping (Result<PageResponse, Error>) -> ()) {
        didSearch = true

        lastSearchTerm = term
        lastSearchLocation = location
        lastOffset = offset

        if nextPageResults.count > 0 {
            completion(nextPageResults.removeFirst())
        }
    }

    var didFetchImage = false
    var previousURLStrings = [String]()
    var nextImageResults: [Result<Data, Error>] = []

    func fetchImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> ()) {
        didFetchImage = true
        previousURLStrings.append(urlString)

        if nextImageResults.count > 0 {
            completion(nextImageResults.removeFirst())
        }
    }

    var lastAutoCompleteTerm: String?
    var lastAutoCompleteLocation: CLLocation?
    var nextAutoCompleteResult: Result<[String], Error>?

    func autocomplete(term: String, location: CLLocation, completion: @escaping (Result<[String], Error>) -> ()) {
        lastAutoCompleteTerm = term
        lastAutoCompleteLocation = location

        if let nextAutoCompleteResult = nextAutoCompleteResult {
            completion(nextAutoCompleteResult)
        }
    }
}
