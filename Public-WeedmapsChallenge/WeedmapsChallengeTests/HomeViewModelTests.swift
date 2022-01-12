//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import XCTest
@testable import WeedmapsChallenge

class HomeViewModelTests: XCTestCase {
    func test__getPreviousSearches__willRestorePreviousSearchesFromCache() {
        let mockAPI = MockYellowPagesAPI()
        let mockSearchCache = MockSearchCache()
        mockSearchCache.nextPreviousSearches = ["search 1", "search 2"]
        let subject = SearchViewModel(api: mockAPI, searchCache: mockSearchCache)

        let previousSearches = subject.previousSearches

        XCTAssertEqual(previousSearches, ["search 1", "search 2"])
        XCTAssertTrue(mockSearchCache.didRead)
    }

    func test__search__withLocation__success__willCallDelegate__updateImageData__updateSearchCache() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", rating: 0, url: "some url 1", price: "some price 1", imageURL: "some image url 1"),
                                Business(id: "some id 2", name: "some name 2", rating: 0, url: "some url 2", price: "some price 2", imageURL: "some image url 2")
                            ]
                    )
            )
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let mockSearchCache = MockSearchCache()
        let subject = SearchViewModel(api: mockAPI, searchCache: mockSearchCache)
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastSearchTerm, "some term")
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.latitude, CLLocationDegrees(37.786882))
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.longitude, CLLocationDegrees(-122.399972))
        XCTAssertEqual(mockDelegate.numberOfSearches, 1)
        XCTAssertTrue(mockSearchCache.didWrite)
        XCTAssertEqual(subject.businesses.count, 2)
        XCTAssertEqual(subject.imageCache.count, 2)
        XCTAssertTrue(subject.previousSearches.contains("some term"))
    }

    func test__searchingNewTerm__overwriteOldResults__storeTermOnceInCache() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", rating: 0, url: "some url 1", price: "some price 1", imageURL: "some image url 1"),
                                Business(id: "some id 2", name: "some name 2", rating: 0, url: "some url 2", price: "some price 2", imageURL: "some image url 2")
                            ]
                    )
            ),
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", rating: 0, url: "some url 1", price: "some price 1", imageURL: "some image url 1")
                            ]
                    )
            )
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastSearchTerm, "some term")
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.latitude, CLLocationDegrees(37.786882))
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.longitude, CLLocationDegrees(-122.399972))
        XCTAssertEqual(mockDelegate.numberOfSearches, 1)
        XCTAssertEqual(subject.businesses.count, 2)
        XCTAssertEqual(subject.imageCache.count, 2)

        subject.search(term: "another term")

        XCTAssertEqual(mockAPI.lastSearchTerm, "another term")
        XCTAssertEqual(subject.businesses.count, 1)
        XCTAssertEqual(subject.imageCache.count, 1)
    }

    func test__search__getMoreResults__usesPreviousSearchTerm__appendsNewBusinesses() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", rating: 0, url: "some url 1", price: "some price 1", imageURL: "some image url 1"),
                                Business(id: "some id 2", name: "some name 2", rating: 0, url: "some url 2", price: "some price 2", imageURL: "some image url 2")
                            ]
                    )
            ),
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 3", name: "some name 3", rating: 0, url: "some url 3", price: "some price 3", imageURL: "some image url 3"),
                                Business(id: "some id 4", name: "some name 4", rating: 0, url: "some url 4", price: "some price 4", imageURL: "some image url 4"),
                                Business(id: "some id 5", name: "some name 5", rating: 0, url: "some url 5", price: "some price 5", imageURL: "some image url 5")
                            ]
                    )
            )
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastSearchTerm, "some term")
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.latitude, CLLocationDegrees(37.786882))
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.longitude, CLLocationDegrees(-122.399972))
        XCTAssertEqual(mockDelegate.numberOfSearches, 1)
        XCTAssertEqual(subject.businesses.count, 2)
        XCTAssertEqual(subject.imageCache.count, 2)

        subject.loadNextPageOfBusinesses()

        XCTAssertEqual(mockAPI.lastSearchTerm, "some term")
        XCTAssertEqual(mockAPI.lastOffset, 2)
        XCTAssertEqual(mockDelegate.numberOfSearches, 2)
        XCTAssertEqual(subject.businesses.count, 5)
        XCTAssertEqual(subject.imageCache.count, 5)
        XCTAssertTrue(subject.previousSearches.contains("some term"))
        XCTAssertEqual(subject.previousSearches.count, 1)
    }

    func test__search__withLocation__failure__willCallDelegateWithFailure() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [.failure(YelpError.unexpected(code: -1))]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastSearchTerm, "some term")
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.latitude, CLLocationDegrees(37.78))
        XCTAssertEqual(mockAPI.lastSearchLocation?.coordinate.longitude, CLLocationDegrees(-122.39))
        XCTAssertEqual(mockDelegate.numberOfSearches, 0)
        XCTAssertTrue(mockDelegate.searchDidFail)
        XCTAssertEqual(mockDelegate.searchErrors[0], YelpError.unexpected(code: -1))
        XCTAssertEqual(subject.businesses.count, 0)
    }

    func test__search__withoutLocation__doesNothing() {
        let mockAPI = MockYellowPagesAPI()
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate

        subject.search(term: "some term")

        XCTAssertFalse(mockAPI.didSearch)
        XCTAssertEqual(mockDelegate.numberOfSearches, 0)
    }

    func test__loadNextPageOfBusinesses__lastTermIsNil__doNothing() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [.success(PageResponse(businesses: [
            Business(id: "some id 1", name: "some name 1", rating: 0, url: "some url 1", price: "some price 1", imageURL: "some image url 1")
        ]))]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.loadNextPageOfBusinesses()

        XCTAssertEqual(subject.businesses.count, 0)
        XCTAssertNil(mockAPI.lastSearchTerm)
        XCTAssertNil(mockAPI.lastSearchLocation)
        XCTAssertEqual(mockDelegate.numberOfSearches, 0)
    }

    func test__fetchImageData__success__willCallDelegate__storeData() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", rating: 0, url: "some url 1", price: "some price 1", imageURL: "some image url 1"),
                                Business(id: "some id 2", name: "some name 2", rating: 0, url: "some url 2", price: "some price 2", imageURL: "some image url 2"),
                                Business(id: "some id 3", name: "some name 3", rating: 0, url: "some url 3", price: "some price 3", imageURL: "some image url 3")
                            ]
                    )
            )
        ]
        mockAPI.nextImageResults = [
            .success("first".data(using: .utf8)!),
            .success("second".data(using: .utf8)!),
            .success("third".data(using: .utf8)!)
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])
        subject.search(term: "whatever")

        subject.fetchImageData(index: 0, urlString: "http://www.image0.com")
        subject.fetchImageData(index: 1, urlString: "http://www.image1.com")
        subject.fetchImageData(index: 2, urlString: "http://www.image2.com")

        XCTAssertTrue(mockAPI.didFetchImage)
        XCTAssertEqual(mockAPI.previousURLStrings[0], "http://www.image0.com")
        XCTAssertEqual(mockDelegate.fetchedImageRows[0], 0)
        XCTAssertEqual(mockDelegate.imageData[0], "first".data(using: .utf8))
        XCTAssertEqual(mockAPI.previousURLStrings[1], "http://www.image1.com")
        XCTAssertEqual(mockDelegate.fetchedImageRows[1], 1)
        XCTAssertEqual(mockDelegate.imageData[1], "second".data(using: .utf8))
        XCTAssertEqual(mockAPI.previousURLStrings[2], "http://www.image2.com")
        XCTAssertEqual(mockDelegate.fetchedImageRows[2], 2)
        XCTAssertEqual(mockDelegate.imageData[2], "third".data(using: .utf8))
        XCTAssertEqual(subject.imageCache[0], "first".data(using: .utf8))
        XCTAssertEqual(subject.imageCache[1], "second".data(using: .utf8))
        XCTAssertEqual(subject.imageCache[2], "third".data(using: .utf8))
    }

    func test__fetchImageData__failure__willCallDelegateWithError() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextImageResults = [.failure(YelpError.badRequest)]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate

        subject.fetchImageData(index: 0, urlString: "http://www.image0.com")

        XCTAssertTrue(mockAPI.didFetchImage)
        XCTAssertEqual(mockAPI.previousURLStrings[0], "http://www.image0.com")
        XCTAssertTrue(mockDelegate.imageFetchDidFail)
        XCTAssertEqual(mockDelegate.failedImageRows[0], 0)
        XCTAssertEqual(mockDelegate.imageFetchErrors[0], YelpError.badRequest)
        XCTAssertEqual(mockDelegate.fetchedImageRows.count, 0)
        XCTAssertEqual(mockDelegate.imageData.count, 0)
    }

    func test__autoComplete__withLocation__success__callDelegate() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextAutoCompleteResult = .success([String]())
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])

        subject.autoComplete(term: "some term")

        XCTAssertEqual(mockAPI.lastAutoCompleteTerm, "some term")
        XCTAssertEqual(mockAPI.lastAutoCompleteLocation?.coordinate.latitude, CLLocationDegrees(37.78))
        XCTAssertEqual(mockAPI.lastAutoCompleteLocation?.coordinate.longitude, CLLocationDegrees(-122.39))
        XCTAssertEqual(subject.autoCompleteStrings.count, 0)
        XCTAssertTrue(mockDelegate.didCallAutoComplete)
    }

    func test__autoComplete__withoutLocation__doesNothing() {
        let mockAPI = MockYellowPagesAPI()
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate

        subject.autoComplete(term: "some term")

        XCTAssertFalse(mockAPI.didSearch)
        XCTAssertEqual(mockDelegate.numberOfSearches, 0)
    }

    func test__autoComplete__withLocation__failure__willCallDelegateWithFailure() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextAutoCompleteResult = .failure(YelpError.unexpected(code: -1))
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI, searchCache: MockSearchCache())
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])

        subject.autoComplete(term: "some term")

        XCTAssertEqual(mockAPI.lastAutoCompleteTerm, "some term")
        XCTAssertEqual(mockAPI.lastAutoCompleteLocation?.coordinate.latitude, CLLocationDegrees(37.78))
        XCTAssertEqual(mockAPI.lastAutoCompleteLocation?.coordinate.longitude, CLLocationDegrees(-122.39))
        XCTAssertFalse(mockDelegate.didCallAutoComplete)
        XCTAssertTrue(mockDelegate.didCallAutoCompleteDidFail)
        XCTAssertEqual(mockDelegate.autoCompleteErrors[0], YelpError.unexpected(code: -1))
        XCTAssertEqual(subject.autoCompleteStrings.count, 0)
    }
}

fileprivate let expectedLocation = CLLocation(latitude: CLLocationDegrees(37.78), longitude: CLLocationDegrees(-122.39))