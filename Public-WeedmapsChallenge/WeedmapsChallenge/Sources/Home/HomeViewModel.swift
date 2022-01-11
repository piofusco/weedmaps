//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation

protocol HomeViewModel: AnyObject {
    var businesses: [Business] { get }
    var imageCache: [Data?] { get }
    var autoCompleteResponse: AutoCompleteResponse? { get }
    var delegate: HomeViewModelDelegate? { get set }

    func search(term: String)
    func loadNextPageOfBusinesses()
    func fetchImageData(index: Int, urlString: String)
    func autoComplete(term: String)
}

class SearchViewModel: NSObject, HomeViewModel {
    private(set) var businesses: [Business] = []
    private(set) var imageCache: [Data?] = []
    private(set) var autoCompleteResponse: AutoCompleteResponse?
    private var location: CLLocation?
    private var lastSearchedTerm: String?
    private var lastAutoCompleteTerm: String?

    weak var delegate: HomeViewModelDelegate?

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
                    self.imageCache.append(contentsOf: [Data?](repeating: nil, count: response.businesses.count))
                } else {
                    self.businesses = response.businesses
                    self.imageCache = [Data?](repeating: nil, count: self.businesses.count)
                }
                self.delegate?.didSearch()
            case .failure(let error):
                self.delegate?.searchDidFail(with: error)
            }
        }
    }

    func fetchImageData(index: Int, urlString: String) {
        api.fetchImageData(urlString: urlString) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.delegate?.didFetchImage(for: index, data: data)
                self.imageCache[index] = data
            case .failure(let error):
                self.delegate?.imageFetchFailed(for: index, with: error)
            }
        }
    }

    func autoComplete(term: String) {
        guard let location = location else { return }
        lastAutoCompleteTerm = term

        api.autocomplete(term: term, location: location) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.autoCompleteResponse = response
                self.delegate?.didAutoComplete()
            case .failure(let error):
                self.delegate?.autoCompleteDidFail(with: error)
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
