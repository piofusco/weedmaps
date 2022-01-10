//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let padding = 15.0
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(
                width: (UIScreen.main.bounds.width / 2) - (padding * 2),
                height: UIScreen.main.bounds.width / 2
        )
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(BusinessCollectionViewCell.self, forCellWithReuseIdentifier: "BusinessCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private var searchController = UISearchController(searchResultsController: nil)

    private let viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    override func loadView() {
        super.loadView()

        navigationItem.title = "Search"

        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.search(term: "banana")
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.businesses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCollectionViewCell", for: indexPath) as? BusinessCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.setupViews(name: viewModel.businesses[indexPath.row].name)

        return cell
    }
}

extension HomeViewController: SearchViewModelDelegate {
    func searchDidFinish(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.collectionView.reloadData()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // IMPLEMENT:
        // 1a) Present the user with a UIAlertController (action sheet style) with options
        // to either display the Business's Yelp page in a WKWebView OR bump the user out to
        // Safari. Both options should display the Business's Yelp page details
    }
}
extension HomeViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // IMPLEMENT: Be sure to consider things like network errors
        // and possible rate limiting from the Yelp API. If the user types
        // very quickly, how will you prevent unnecessary requests from firing
        // off? Be sure to leverage the searchDataTask and use it wisely!
    }
}
