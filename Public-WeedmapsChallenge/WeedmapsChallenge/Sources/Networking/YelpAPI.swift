//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation

protocol YellowPagesAPI {
    func search(term: String, location: CLLocation, offset: Int, completion: @escaping (Result<PageResponse, Error>) -> ())
    func fetchImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void)

    func autocomplete(term: String, location: CLLocation, completion: @escaping (Result<AutoCompleteResponse, Error>) -> ())
}

class YelpAPI: YellowPagesAPI {
    private lazy var baseURLComponents: URLComponents = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.yelp.com"
        return urlComponents
    }()

    fileprivate let apiKey = "EVgb3CNoYvRGgR2Elu6gpThMZMWJBrJP-XPNGSzM9-uO-mm316e3XxWqPXiHkB9KxW_B4WEQe4Jw82A44KGuBri6Wk_kgM1UioFgLimIY_Z2jUnqjfhqwEx6JyvbYXYx"

    private let urlSession: WeedmapsURLSession
    private let decoder: WeedmapsJSONDecoder

    init(urlSession: WeedmapsURLSession, decoder: WeedmapsJSONDecoder) {
        self.urlSession = urlSession
        self.decoder = decoder
    }

    func search(term: String, location: CLLocation, offset: Int = 0, completion: @escaping (Result<PageResponse, Error>) -> ()) {
        var urlComponents = baseURLComponents
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "15"),
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
            URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
        ]
        urlComponents.path = "/v3/businesses/search"

        guard let url = urlComponents.url else {
            completion(Result.failure(YelpError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        urlSession.makeDataTask(with: request) { [weak self] data, response, error in
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

    func fetchImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> ()) {
        guard let url = URL(string: urlString) else { return }

        urlSession.makeDataTask(with: URLRequest(url: url)) { data, response, error in
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

                completion(Result.success(data))
            case 400..<499: completion(Result.failure(YelpError.badRequest))
            case 500..<599: completion(Result.failure(YelpError.internalServerError))
            default: completion(Result.failure(YelpError.unexpected(code: -1)))
            }
        }.resume()
    }

    func autocomplete(term: String, location: CLLocation, completion: @escaping (Result<AutoCompleteResponse, Error>) -> ()) {
        var urlComponents = baseURLComponents
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
            URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
        ]
        urlComponents.path = "/v3/autocomplete"

        guard let url = urlComponents.url else {
            completion(Result.failure(YelpError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        urlSession.makeDataTask(with: request) { [weak self] data, response, error in
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

                var response: AutoCompleteResponse?
                do {
                    response = try self.decoder.decode(AutoCompleteResponse.self, from: data)
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