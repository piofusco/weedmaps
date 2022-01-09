//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation

protocol SearchViewModelDelegate: AnyObject {
    func searchDidFinish(success: Bool)
}

protocol HomeViewModel: AnyObject {
    var businesses: [Business] { get }

    func search(term: String)
    func loadNextPageOfBusinesses()
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
                self.delegate?.searchDidFinish(success: true)
            case .failure(let error):
                self.delegate?.searchDidFinish(success: false)
            }
        }
    }
}

extension SearchViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            switch manager.authorizationStatus {
            case .authorizedAlways: print("status is now authorizedAlways")
            case .authorizedWhenInUse: print("status is now authorizedWhenInUse")
            case .denied: print("status is now denied")
            case .notDetermined: print("status is now notDetermined")
            case .restricted: print("status is now restricted")
            @unknown default: print("status is now unknown")
            }
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways: print("status is now authorizedAlways")
            case .authorizedWhenInUse: print("status is now authorizedWhenInUse")
            case .denied: print("status is now denied")
            case .notDetermined: print("status is now notDetermined")
            case .restricted: print("status is now restricted")
            @unknown default: print("status is now unknown")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            self.location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle failure to get a user’s location
    }
}
