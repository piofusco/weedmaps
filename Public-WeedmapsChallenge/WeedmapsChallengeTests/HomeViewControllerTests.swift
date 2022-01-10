//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

class HomeViewControllerTests: XCTestCase {
    func test__UICollectionViewDataSource__cellForRow__loadDataFromAPIWithImageURL__onlyIfNil() {
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

    func test__UICollectionViewDataSource__willDisplayCell__onlyLoadNewAfterLastFifth() {
        let mockHomeViewModel = MockHomeViewModel()
        mockHomeViewModel.nextBusinesses = [
            Business(id: "id 1", name: "name 1", url: "url 1", price: "", imageURL: "https://www.image1.com"),
            Business(id: "id 2", name: "name 2", url: "url 2", price: "", imageURL: "https://www.image2.com"),
            Business(id: "id 3", name: "name 3", url: "url 3", price: "", imageURL: "https://www.image3.com"),
            Business(id: "id 4", name: "name 4", url: "url 4", price: "", imageURL: "https://www.image4.com"),
            Business(id: "id 5", name: "name 5", url: "url 5", price: "", imageURL: "https://www.image5.com"),
            Business(id: "id 6", name: "name 6", url: "url 6", price: "", imageURL: "https://www.image6.com"),
        ]
        mockHomeViewModel.nextImageData = [
            "first".data(using: .utf8)!,
            "second".data(using: .utf8)!,
            "third".data(using: .utf8)!,
            "fouth".data(using: .utf8)!,
            "fifth".data(using: .utf8)!,
            "sixth".data(using: .utf8)!,
        ]
        let mockMainQueue = MockMainQueue()
        let subject = HomeViewController(viewModel: mockHomeViewModel, mainQueue: mockMainQueue)
        mockHomeViewModel.delegate = subject
        _ = subject.view
        let firstCell = subject.collectionView(stubCollectionView, cellForItemAt: IndexPath(row: 0, section: 0))
        let secondCell = subject.collectionView(stubCollectionView, cellForItemAt: IndexPath(row: 1, section: 0))

        subject.collectionView(stubCollectionView, willDisplay: firstCell, forItemAt: IndexPath(row: 0, section: 0))

        XCTAssertFalse(mockHomeViewModel.didLoadNextPage)
        XCTAssertEqual(mockMainQueue.numberOfAsyncCalls, 1)

        subject.collectionView(stubCollectionView, willDisplay: secondCell, forItemAt: IndexPath(row: 1, section: 0))

        XCTAssertTrue(mockHomeViewModel.didLoadNextPage)
        XCTAssertEqual(mockMainQueue.numberOfAsyncCalls, 2)
    }

    func test__SearchViewModelDelegate__didFetchImage__callsDispatchQueue() {
        let mockHomeViewModel = MockHomeViewModel()
        let mockMainQueue = MockMainQueue()
        let subject = HomeViewController(viewModel: mockHomeViewModel, mainQueue: mockMainQueue)

        subject.didFetchImage(for: 0, data: "".data(using: .utf8)!)

        XCTAssertEqual(mockMainQueue.numberOfAsyncCalls, 1)
    }
}

fileprivate var stubCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.register(BusinessCollectionViewCell.self, forCellWithReuseIdentifier: "BusinessCollectionViewCell")
    return collectionView
}()