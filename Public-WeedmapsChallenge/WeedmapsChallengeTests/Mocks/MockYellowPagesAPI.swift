//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//
import CoreLocation

@testable import WeedmapsChallenge

class MockYellowPagesAPI: YellowPagesAPI {
    var didSearch = false
    var lastTerm: String?
    var lastLocation: CLLocation?
    public var lastOffset: Int?

    var nextResults: [Result<PageResponse, Error>] = []


    func search(term: String, location: CLLocation, offset: Int, completion: @escaping (Result<PageResponse, Error>) -> ()) {
        didSearch = true

        lastTerm = term
        lastLocation = location
        lastOffset = offset

        if nextResults.count > 0 {
            completion(nextResults.removeFirst())
        }
    }

    func fetchImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> ()) {

    }
}
