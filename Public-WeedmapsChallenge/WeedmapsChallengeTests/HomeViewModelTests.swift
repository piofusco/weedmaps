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
        mockAPI.nextResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1"),
                                Business(id: "some id 2", name: "some name 2"),
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
        guard let lastSuccess = mockDelegate.lastSuccess else {
            XCTFail("last success never set")
            return
        }
        XCTAssertTrue(lastSuccess)
        XCTAssertEqual(subject.businesses.count, 2)
    }

    func test__searchingNewTerm__overwriteOldResults() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1"),
                                Business(id: "some id 2", name: "some name 2"),
                            ]
                    )
            ),
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1")
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
        guard let lastSuccess = mockDelegate.lastSuccess else {
            XCTFail("last success never set")
            return
        }
        XCTAssertTrue(lastSuccess)
        XCTAssertEqual(subject.businesses.count, 2)

        subject.search(term: "another term")

        XCTAssertEqual(mockAPI.lastTerm, "another term")
        XCTAssertEqual(subject.businesses.count, 1)
    }

    func test__search__getMoreResults__usesPreviousSearchTerm__appendsNewBusinesses() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextResults = [
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 1", name: "some name 1"),
                                Business(id: "some id 2", name: "some name 2"),
                            ]
                    )
            ),
            .success(
                    PageResponse(
                            businesses: [
                                Business(id: "some id 3", name: "some name 3"),
                                Business(id: "some id 4", name: "some name 4"),
                                Business(id: "some id 5", name: "some name 5"),
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
        guard let lastSuccess = mockDelegate.lastSuccess else {
            XCTFail("last success never set")
            return
        }
        XCTAssertTrue(lastSuccess)
        XCTAssertEqual(subject.businesses.count, 2)

        subject.loadNextPageOfBusinesses()

        XCTAssertEqual(mockAPI.lastTerm, "some term")
        XCTAssertEqual(mockAPI.lastOffset, 2)
        XCTAssertEqual(subject.businesses.count, 5)
    }

    func test__loadNextPageOfBusinesses__lastTermIsNil__doNothing() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextResults = [.success(PageResponse(businesses: [Business(id: "some id 1", name: "some name 1")]))]
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
        XCTAssertNil(mockDelegate.lastSuccess)
    }

    func test__search__withLocation__failure__willCallDelegateWithFailure() {
        let mockAPI = MockYellowPagesAPI()
        mockAPI.nextResults = [.failure(YelpError.unexpected(code: -1))]
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
        guard let lastSuccess = mockDelegate.lastSuccess else {
            XCTFail("last success never set")
            return
        }
        XCTAssertFalse(lastSuccess)
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
}
