//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import XCTest
@testable import WeedmapsChallenge

class HomeViewModelTests: XCTestCase {
    func test__search__withLocation__success__willCallDelegate() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", url: "some url 1", price: "some price 1", imageURL: "some image url 1"),
                                Business(id: "some id 2", name: "some name 2", url: "some url 2", price: "some price 2", imageURL: "some image url 2")
                            ]
                    )
            )
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastTerm, "some term")
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.latitude, CLLocationDegrees(37.786882))
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.longitude, CLLocationDegrees(-122.399972))
        XCTAssertTrue(mockDelegate.didCallSearchBusinesses)
        XCTAssertEqual(subject.businesses.count, 2)
    }

    func test__searchingNewTerm__overwriteOldResults() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", url: "some url 1", price: "some price 1", imageURL: "some image url 1"),
                                Business(id: "some id 2", name: "some name 2", url: "some url 2", price: "some price 2", imageURL: "some image url 2")
                            ]
                    )
            ),
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", url: "some url 1", price: "some price 1", imageURL: "some image url 1")
                            ]
                    )
            )
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastTerm, "some term")
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.latitude, CLLocationDegrees(37.786882))
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.longitude, CLLocationDegrees(-122.399972))
        XCTAssertTrue(mockDelegate.didCallSearchBusinesses)
        XCTAssertEqual(subject.businesses.count, 2)

        subject.search(term: "another term")

        XCTAssertEqual(mockAPI.lastTerm, "another term")
        XCTAssertEqual(subject.businesses.count, 1)
    }

    func test__search__getMoreResults__usesPreviousSearchTerm__appendsNewBusinesses() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1", url: "some url 1", price: "some price 1", imageURL: "some image url 1"),
                                Business(id: "some id 2", name: "some name 2", url: "some url 2", price: "some price 2", imageURL: "some image url 2")
                            ]
                    )
            ),
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 3", name: "some name 3", url: "some url 3", price: "some price 3", imageURL: "some image url 3"),
                                Business(id: "some id 4", name: "some name 4", url: "some url 4", price: "some price 4", imageURL: "some image url 4"),
                                Business(id: "some id 5", name: "some name 5", url: "some url 5", price: "some price 5", imageURL: "some image url 5")
                            ]
                    )
            )
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastTerm, "some term")
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.latitude, CLLocationDegrees(37.786882))
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.longitude, CLLocationDegrees(-122.399972))
        XCTAssertTrue(mockDelegate.didCallSearchBusinesses)
        XCTAssertEqual(subject.businesses.count, 2)

        subject.loadNextPageOfBusinesses()

        XCTAssertEqual(mockAPI.lastTerm, "some term")
        XCTAssertEqual(mockAPI.lastOffset, 2)
        XCTAssertEqual(subject.businesses.count, 5)
    }

    func test__loadNextPageOfBusinesses__lastTermIsNil__doNothing() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [.success(PageResponse(businesses: [
            Business(id: "some id 1", name: "some name 1", url: "some url 1", price: "some price 1", imageURL: "some image url 1")
        ]))]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.loadNextPageOfBusinesses()

        XCTAssertEqual(subject.businesses.count, 0)
        XCTAssertNil(mockAPI.lastTerm)
        XCTAssertNil(mockAPI.lastLocation)
        XCTAssertFalse(mockDelegate.didCallSearchBusinesses)
    }

    func test__search__withLocation__failure__willCallDelegateWithFailure() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextPageResults = [.failure(YelpError.unexpected(code: -1))]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate
        subject.locationManager(CLLocationManager(), didUpdateLocations: [
            CLLocation(latitude: 37.786882, longitude: -122.399972)
        ])

        subject.search(term: "some term")

        XCTAssertEqual(mockAPI.lastTerm, "some term")
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.latitude, CLLocationDegrees(37.786882))
        XCTAssertEqual(mockAPI.lastLocation?.coordinate.longitude, CLLocationDegrees(-122.399972))
        XCTAssertFalse(mockDelegate.didCallSearchBusinesses)
        XCTAssertTrue(mockDelegate.searchDidFail)
        XCTAssertEqual(mockDelegate.searchErrors[0], YelpError.unexpected(code: -1))
        XCTAssertEqual(subject.businesses.count, 0)
    }

    func test__search__withoutLocation__doesNothing() {
        let mockAPI = MockYellowPagesAPI()
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate

        subject.search(term: "some term")

        XCTAssertFalse(mockAPI.didSearch)
        XCTAssertFalse(mockDelegate.didCallSearchBusinesses)
    }

    func test__getImageData__success__willCallDelegate() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextImageResults = [
            .success("first".data(using: .utf8)!),
            .success("second".data(using: .utf8)!),
            .success("third".data(using: .utf8)!),
            .success("fourth".data(using: .utf8)!)
        ]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate

        subject.getImageData(index: 0, urlString: "http://www.image0.com")
        subject.getImageData(index: 1, urlString: "http://www.image1.com")
        subject.getImageData(index: 2, urlString: "http://www.image2.com")

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
    }

    func test__getImageData__failure__willCallDelegateWithError() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextImageResults = [.failure(YelpError.badRequest)]
        let mockDelegate = MockSearchViewModelDelegate()
        let subject = SearchViewModel(api: mockAPI)
        subject.delegate = mockDelegate

        subject.getImageData(index: 0, urlString: "http://www.image0.com")

        XCTAssertTrue(mockAPI.didFetchImage)
        XCTAssertEqual(mockAPI.previousURLStrings[0], "http://www.image0.com")
        XCTAssertTrue(mockDelegate.imageFetchDidFail)
        XCTAssertEqual(mockDelegate.failedImageRows[0], 0)
        XCTAssertEqual(mockDelegate.imageFetchErrors[0], YelpError.badRequest)
        XCTAssertEqual(mockDelegate.fetchedImageRows.count, 0)
        XCTAssertEqual(mockDelegate.imageData.count, 0)
    }
}
