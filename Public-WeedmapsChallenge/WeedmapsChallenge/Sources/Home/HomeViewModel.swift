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
    var imageData: [Data?] { get }
    var delegate: SearchViewModelDelegate? { get set }

    func search(term: String)
    func loadNextPageOfBusinesses()
    func fetchImageData(index: Int, urlString: String)
}

class SearchViewModel: NSObject, HomeViewModel {
    private(set) var businesses: [Business] = []
    private(set) var imageData: [Data?] = []
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

        // Should we wipe old businesses/images here?

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
                    self.imageData.append(contentsOf: [Data?](repeating: nil, count: response.businesses.count))
                } else {
                    self.businesses = response.businesses
                    self.imageData = [Data?](repeating: nil, count: self.businesses.count)
                }
                self.delegate?.didUpdateBusinesses()
            case .failure(let error):
                self.delegate?.searchFailed(with: error)
            }
        }
    }

    func fetchImageData(index: Int, urlString: String) {
        api.fetchImageData(urlString: urlString) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.delegate?.didFetchImage(for: index, data: data)
                self.imageData[index] = data
            case .failure(let error):
                self.delegate?.imageFetchFailed(for: index, with: error)
            }
        }
    }
}

extension SearchViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            self.location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}
