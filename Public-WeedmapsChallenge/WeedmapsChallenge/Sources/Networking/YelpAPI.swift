//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol YellowPagesAPI {
    func search(term: String, completion: @escaping (Result<PageResponse, Error>) -> ())
}

class YelpAPI: YellowPagesAPI {
    private lazy var baseURLComponents: URLComponents = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.yelp.com"
        return urlComponents
    }()

    private let urlSession: WeedmapsURLSession
    private let decoder: WeedmapsJSONDecoder

    init(urlSession: WeedmapsURLSession, decoder: WeedmapsJSONDecoder) {
        self.urlSession = urlSession
        self.decoder = decoder
    }

    func search(term: String, completion: @escaping (Result<PageResponse, Error>) -> ()) {
        guard !term.isEmpty else {
            completion(Result.failure(YelpError.unexpected(code: -1)))
            return
         }

        var urlComponents = baseURLComponents
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "15"),
            URLQueryItem(name: "term", value: term)
        ]
        urlComponents.path = "/v3/businesses/search"

        guard let url = urlComponents.url else {
            completion(Result.failure(YelpError.invalidURL))
            return
        }

        urlSession.makeDataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error { completion(Result.failure(error)) }

            guard let response = response as? HTTPURLResponse else {
                completion(Result.failure(YelpError.unexpected(code: -1)))
                return
            }

            switch response.statusCode {
            case 200..<299:
                guard let data = data else {
                    completion(Result.failure(YelpError.noDataReturned))
                    return
                }

                var response: PageResponse?
                do {
                    response = try self.decoder.decode(PageResponse.self, from: data)
                } catch {
                    completion(Result.failure(YelpError.invalidJSON))
                }

                guard let responseToReturn = response else {
                    completion(Result.failure(YelpError.unexpected(code: -1)))
                    return
                }

                completion(Result.success(responseToReturn))
            case 400..<499: completion(Result.failure(YelpError.badRequest))
            case 500..<599: completion(Result.failure(YelpError.internalServerError))
            default: completion(Result.failure(YelpError.unexpected(code: -1)))
            }
        }.resume()
    }
}