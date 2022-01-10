//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation

protocol SearchViewModelDelegate: AnyObject {
    func didUpdateBusinesses()
    func searchFailed(with error: Error)

    func didFetchImage(for row: Int, data: Data)
    func imageFetchFailed(for row: Int, with error: Error)
}

protocol HomeViewModel: AnyObject {
    var businesses: [Business] { get }
    var delegate: SearchViewModelDelegate? { get set }

    func search(term: String)
    func loadNextPageOfBusinesses()
    func getImageData(index: Int, urlString: String)
}

class SearchViewModel: NSObject, HomeViewModel {
    private(set) var businesses: [Business] = []
    private var location: CLLocation?
    private var lastSearchedTerm: String?

    weak var delegate: SearchViewModelDelegate?

    private let api: YellowPagesAPI

    init(api: YellowPagesAPI) {
        self.api = api
    }

    func search(term: String) {
        guard let location = location else { return }

        lastSearchedTerm = term

        search(term: term, location: location, overwrite: true)
    }

    func loadNextPageOfBusinesses() {
        guard let location = location else { return }
        guard let lastSearchedTerm = lastSearchedTerm else { return }

        search(term: lastSearchedTerm, location: location, overwrite: false)
    }

    private func search(term: String, location: CLLocation, overwrite: Bool) {
        api.search(term: term, location: location, offset: businesses.count) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if !overwrite {
                    self.businesses.append(contentsOf: response.businesses)
                } else {
                    self.businesses = response.businesses
                }
                self.delegate?.didUpdateBusinesses()
            case .failure(let error):
                self.delegate?.searchFailed(with: error)
            }
        }
    }

    func getImageData(index: Int, urlString: String) {
        api.fetchImageData(urlString: urlString) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data): self.delegate?.didFetchImage(for: index, data: data)
            case .failure(let error): self.delegate?.imageFetchFailed(for: index, with: error)
            }
        }
    }
}

extension SearchViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways: print("status is now authorizedAlways")
        case .authorizedWhenInUse: print("status is now authorizedWhenInUse")
        case .denied: print("status is now denied")
        case .notDetermined: print("status is now notDetermined")
        case .restricted: print("status is now restricted")
        @unknown default: print("status is now unknown")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            self.location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
