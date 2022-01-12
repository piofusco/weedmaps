//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import XCTest

@testable import WeedmapsChallenge

class YelpAPITest: XCTestCase {
    func test__search__callResume__ensureRequest() {
        let mockURLSession = MockURLSession()
        let mockURLSessionDataTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockURLSessionDataTask
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())

        subject.search(term: "banana", location: expectedLocation, offset: 0) { _ in }

        XCTAssertTrue(mockURLSessionDataTask.didResume)
        XCTAssertEqual(mockURLSession.lastURL, URL(string: "https://api.yelp.com/v3/businesses/search?limit=15&term=banana&latitude=37.78&longitude=-122.39&offset=0"))
        guard let lastHeaders = mockURLSession.lastHeaders else {
            XCTFail("No headers set")
            return
        }
        guard let authorization = lastHeaders["Authorization"] else {
            XCTFail("Authorization not set")
            return
        }
        XCTAssertEqual(authorization, "Bearer EVgb3CNoYvRGgR2Elu6gpThMZMWJBrJP-XPNGSzM9-uO-mm316e3XxWqPXiHkB9KxW_B4WEQe4Jw82A44KGuBri6Wk_kgM1UioFgLimIY_Z2jUnqjfhqwEx6JyvbYXYx")
    }

    func test__search__200__callCompletionWithData() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextData = businessesJSONResponse
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false
        var returnedBusinessesResponse: PageResponse?

        subject.search(term: "banana", location: expectedLocation) { result in
            completionDidRun = true

            switch result {
            case .success(let businesses): returnedBusinessesResponse = businesses
            case .failure(_): XCTFail("result shouldn't be a failure")
            }
        }

        XCTAssertTrue(completionDidRun)
        XCTAssertEqual(returnedBusinessesResponse?.businesses.count, 2)
    }

    func test__search__200__noData__runCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.search(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__search__200__badData__runCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let mockJSONDecoder = MockJSONDecoder<Business>()
        mockJSONDecoder.nextDecodable = Business(id: "", name: "", rating: 0, url: "", price: "", imageURL: "")
        let subject = YelpAPI(urlSession: mockURLSession, decoder: mockJSONDecoder)
        var completionDidRun = false

        subject.search(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__search__400__callCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.BadRequestError]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.search(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__search__500__callCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.InternalServerError]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.search(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__search__error__callCompletionWithError() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextError = NSError(domain: "doesn't matter", code: 666)
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.search(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(_): completionDidRun = true
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__fetchImageData__callResume__ensureURL() {
        let mockURLSession = MockURLSession()
        let mockURLSessionDataTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockURLSessionDataTask
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())

        subject.fetchImageData(urlString: "https://rickandmortyapi.com/api/character/avatar/1.jpeg") { _ in }

        XCTAssertTrue(mockURLSessionDataTask.didResume)
        XCTAssertEqual(mockURLSession.lastURL, URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"))
    }

    func test__fetchImageData__200__callCompletionWithData() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextData = "some image data lol".data(using: .utf8)
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.fetchImageData(urlString: "https://rickandmortyapi.com/api/character/avatar/1.jpeg") { result in
            switch result {
            case .success(let data): completionDidRun = true
            case .failure(_): XCTFail("should not succeed")
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__fetchImageData__200__noData__callCompletionWithError() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.fetchImageData(urlString: "https://rickandmortyapi.com/api/character/avatar/1.jpeg") { result in
            switch result {
            case .success(_): XCTFail("result shouldn't succeed")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__fetchImageData__error__callCompletionWithError() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextError = NSError(domain: "doesn't matter", code: 666)
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.fetchImageData(urlString: "https://rickandmortyapi.com/api/character/avatar/1.jpeg") { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(_): completionDidRun = true
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__fetchImageData__400__callCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.BadRequestError]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.fetchImageData(urlString: "https://rickandmortyapi.com/api/character/avatar/1.jpeg") { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__fetchImageData__500__callCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.InternalServerError]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.fetchImageData(urlString: "https://rickandmortyapi.com/api/character/avatar/1.jpeg") { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__fetchImageData__invalidURL__doNothing() {
        let subject = YelpAPI(urlSession: MockURLSession(), decoder: JSONDecoder())
        var completionDidRun = false

        subject.fetchImageData(urlString: "not a url lol") { result in
            completionDidRun = true
            XCTFail("shouldn't call completion")
        }

        XCTAssertFalse(completionDidRun)
    }

    func test__autocomplete__callResume__ensureRequest() {
        let mockURLSession = MockURLSession()
        let mockURLSessionDataTask = MockURLSessionDataTask()
        mockURLSession.nextDataTask = mockURLSessionDataTask
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())

        subject.autocomplete(term: "banana", location: expectedLocation) { _ in }

        XCTAssertTrue(mockURLSessionDataTask.didResume)
        XCTAssertEqual(mockURLSession.lastURL, URL(string: "https://api.yelp.com/v3/autocomplete?text=banana&latitude=37.78&longitude=-122.39"))
        guard let lastHeaders = mockURLSession.lastHeaders else {
            XCTFail("No headers set")
            return
        }
        guard let authorization = lastHeaders["Authorization"] else {
            XCTFail("Authorization not set")
            return
        }
        XCTAssertEqual(authorization, "Bearer EVgb3CNoYvRGgR2Elu6gpThMZMWJBrJP-XPNGSzM9-uO-mm316e3XxWqPXiHkB9KxW_B4WEQe4Jw82A44KGuBri6Wk_kgM1UioFgLimIY_Z2jUnqjfhqwEx6JyvbYXYx")
    }

    func test__autocomplete__200__callCompletionWithData() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextData = autocompleteJSONResponse
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false
        var autoCompleteResponses: [String]?

        subject.autocomplete(term: "banana", location: expectedLocation) { result in
            completionDidRun = true

            switch result {
            case .success(let response): autoCompleteResponses = response
            case .failure(_): XCTFail("result shouldn't be a failure")
            }
        }

        XCTAssertTrue(completionDidRun)
        XCTAssertEqual(autoCompleteResponses?.count, 6)
    }

    func test__autocomplete__200__noData__runCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.autocomplete(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__autocomplete__200__badData__runCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.Happy200Request]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let mockJSONDecoder = MockJSONDecoder<Business>()
        mockJSONDecoder.nextDecodable = Business(id: "", name: "", rating: 0, url: "", price: "", imageURL: "")
        let subject = YelpAPI(urlSession: mockURLSession, decoder: mockJSONDecoder)
        var completionDidRun = false

        subject.autocomplete(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__autocomplete__400__callCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.BadRequestError]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.autocomplete(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__autocomplete__500__callCompletionWithFailure() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextResponses = [HTTPURLResponse.InternalServerError]
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.autocomplete(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(let error):
                completionDidRun = true
                XCTAssertTrue(error is YelpError)
            }
        }

        XCTAssertTrue(completionDidRun)
    }

    func test__autocomplete__error__callCompletionWithError() {
        let mockURLSession = MockURLSession()
        mockURLSession.nextError = NSError(domain: "doesn't matter", code: 666)
        mockURLSession.nextDataTask = MockURLSessionDataTask()
        let subject = YelpAPI(urlSession: mockURLSession, decoder: JSONDecoder())
        var completionDidRun = false

        subject.autocomplete(term: "banana", location: expectedLocation) { result in
            switch result {
            case .success(_): XCTFail("result shouldn't be a failure")
            case .failure(_): completionDidRun = true
            }
        }

        XCTAssertTrue(completionDidRun)
    }

}

extension HTTPURLResponse {
    static var Happy200Request = HTTPURLResponse(url: URL(string: "https://does.not.matter")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static var BadRequestError = HTTPURLResponse(url: URL(string: "https://does.not.matter")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
    static var InternalServerError = HTTPURLResponse(url: URL(string: "https://does.not.matter")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
}

fileprivate let businessesJSONResponse = """
{
    "businesses": [
        {
            "id": "FmGF1B-Rpsjq1f5b56qMwg",
            "name": "Molinari Delicatessen",
            "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/4gRY9rVs8JyHvngljSzXyA/o.jpg",
            "is_closed": false,
            "url": "https://www.yelp.com/biz/molinari-delicatessen-san-francisco?adjust_creative=Q7rOsXWv-6wvxAZqVkzy8A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=Q7rOsXWv-6wvxAZqVkzy8A",
            "rating": 4.5,
            "coordinates": {
                "latitude": 37.79838,
                "longitude": -122.40782
            },
            "transactions": [
                "pickup",
                "delivery"
            ],
            "price": "$$",
            "location": {
                "address1": "373 Columbus Ave",
                "address2": "",
                "address3": "",
                "city": "San Francisco",
                "zip_code": "94133",
                "country": "US",
                "state": "CA",
                "display_address": [
                    "373 Columbus Ave",
                    "San Francisco, CA 94133"
                ]
            },
            "phone": "+14154212337",
            "display_phone": "(415) 421-2337",
            "distance": 1465.2460213942109
        },
        {
            "id": "BcW0vRdM8N-rteR2FfV1jg",
            "name": "Deli Board",
            "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/m5dL_mNk9rjSJ5jQu17hVw/o.jpg",
            "is_closed": false,
            "url": "https://www.yelp.com/biz/deli-board-san-francisco?adjust_creative=Q7rOsXWv-6wvxAZqVkzy8A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=Q7rOsXWv-6wvxAZqVkzy8A",
            "review_count": 1491,
            "categories": [
                {
                    "alias": "delis",
                    "title": "Delis"
                },
                {
                    "alias": "sandwiches",
                    "title": "Sandwiches"
                }
            ],
            "rating": 4.5,
            "coordinates": {
                "latitude": 37.7776247966103,
                "longitude": -122.407012712007
            },
            "transactions": [
                "delivery"
            ],
            "price": "$$",
            "location": {
                "address1": "1058 Folsom St",
                "address2": "",
                "address3": "",
                "city": "San Francisco",
                "zip_code": "94103",
                "country": "US",
                "state": "CA",
                "display_address": [
                    "1058 Folsom St",
                    "San Francisco, CA 94103"
                ]
            },
            "phone": "+14155527687",
            "display_phone": "(415) 552-7687",
            "distance": 1201.0092939107112
        }
    ],
    "total": 240
}
""".data(using: .utf8)

fileprivate let autocompleteJSONResponse = """
{
    "categories": [
        {
            "alias": "appliances",
            "title": "Appliances"
        },
        {
            "alias": "homeappliancerepair",
            "title": "Appliances & Repair"
        }
    ],
    "businesses": [
        {
            "id": "EOM6CItD6sI5P3a-JV61_Q",
            "name": "Applebee's Grill + Bar"
        },
        {
            "id": "dw3ynParaDTHdOanoxyf1Q",
            "name": "Apple Union Square"
        }
    ],
    "terms": [
        {
            "text": "Apple Picking Farm"
        },
        {
            "text": "Apple Hill Farms"
        }
    ]
}
""".data(using: .utf8)

fileprivate let expectedLocation = CLLocation(latitude: CLLocationDegrees(37.78), longitude: CLLocationDegrees(-122.39))
