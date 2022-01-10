//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

class HomeViewControllerTests: XCTestCase {
    func test__cellForRow__loadDataFromAPIWithImageURL__onlyIfNil() {
        let mockHomeViewModel = MockHomeViewModel()
        mockHomeViewModel.nextBusinesses = [
            Business(id: "id 1", name: "name 1", url: "url 1", price: "", imageURL: "https://www.image1.com"),
            Business(id: "id 2", name: "name 2", url: "url 2", price: "", imageURL: "https://www.image2.com"),
            Business(id: "id 3", name: "name 3", url: "url 3", price: "", imageURL: "https://www.image3.com"),
        ]
        mockHomeViewModel.nextImageData = [
            nil,
            nil,
            "".data(using: .utf8)!
        ]
        let subject = HomeViewController(viewModel: mockHomeViewModel, mainQueue: MockMainQueue())
        _ = subject.view
        let stubCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        stubCollectionView.register(BusinessCollectionViewCell.self, forCellWithReuseIdentifier: "BusinessCollectionViewCell")

        _ = subject.collectionView(stubCollectionView, cellForItemAt: IndexPath(row: 0, section: 0))
        _ = subject.collectionView(stubCollectionView, cellForItemAt: IndexPath(row: 1, section: 0))
        _ = subject.collectionView(stubCollectionView, cellForItemAt: IndexPath(row: 2, section: 0))

        XCTAssertEqual(mockHomeViewModel.imageURLStrings[0], "https://www.image1.com")
        XCTAssertEqual(mockHomeViewModel.imageIndices[0], 0)
        XCTAssertEqual(mockHomeViewModel.imageURLStrings[1], "https://www.image2.com")
        XCTAssertEqual(mockHomeViewModel.imageIndices[1], 1)
        XCTAssertEqual(mockHomeViewModel.imageURLStrings.count, 2)
        XCTAssertEqual(mockHomeViewModel.imageIndices.count, 2)
    }

    func test__SearchViewModelDelegate__didFetchImage__callsDispatchQueue() {
        let mockHomeViewModel = MockHomeViewModel()
        let mockMainQueue = MockMainQueue()
        let subject = HomeViewController(viewModel: mockHomeViewModel, mainQueue: mockMainQueue)

        subject.didFetchImage(for: 0, data: "".data(using: .utf8)!)

        XCTAssertTrue(mockMainQueue.didAsync)
    }
}