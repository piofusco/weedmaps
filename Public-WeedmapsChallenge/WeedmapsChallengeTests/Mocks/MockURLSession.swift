//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

@testable import WeedmapsChallenge

class MockURLSession: WeedmapsURLSession {
    var lastURL: URL?

    var nextData: Data?
    var nextResponses: [HTTPURLResponse] = []
    var nextError: Error?

    var nextDataTask: WeedmapsURLSessionDataTask?

    func makeDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) -> WeedmapsURLSessionDataTask {
        lastURL = request.url

        var nextResponse: HTTPURLResponse?
        if nextResponses.count > 0 {
            nextResponse = nextResponses.removeFirst()
        }

        completionHandler(nextData, nextResponse, nextError)

        guard let nextDataTask = nextDataTask else { fatalError("next data task not set") }
        return nextDataTask
    }
}

class MockURLSessionDataTask: WeedmapsURLSessionDataTask {
    var didResume = false
    var resumeNumberOfInvocations = 0

    func resume() {
        didResume = true
        resumeNumberOfInvocations += 1
    }
}