//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol WeedmapsURLSession {
    func makeDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> WeedmapsURLSessionDataTask
}

extension URLSession: WeedmapsURLSession {
    func makeDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> WeedmapsURLSessionDataTask {
        dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

public protocol WeedmapsURLSessionDataTask {
    func resume()
}

extension URLSessionDataTask: WeedmapsURLSessionDataTask {}