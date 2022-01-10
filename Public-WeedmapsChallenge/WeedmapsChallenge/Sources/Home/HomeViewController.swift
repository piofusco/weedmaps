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
    private let mainQueue: MainQueue

    init(viewModel: HomeViewModel, mainQueue: MainQueue) {
        self.viewModel = viewModel
        self.mainQueue = mainQueue

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

        cell.setupLabels(name: viewModel.businesses[indexPath.row].name)

        if let imageData = viewModel.imageData[indexPath.row] {
            cell.updateImage(data: imageData)
        } else {
            viewModel.fetchImageData(index: indexPath.row, urlString: viewModel.businesses[indexPath.row].imageURL)
        }

        return cell
    }
}

extension HomeViewController: SearchViewModelDelegate {
    func didUpdateBusinesses() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.collectionView.reloadData()
        }
    }

    func searchFailed(with error: Error) {

    }

    func didFetchImage(for row: Int, data: Data) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }

            self.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        }
    }

    func imageFetchFailed(for row: Int, with error: Error) {
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row >= 0 && indexPath.row < viewModel.businesses.count else { return }
        guard let url = URL(string: viewModel.businesses[indexPath.row].url) else { return }

        let alert = UIAlertController(title: "Go to business website", message: "", preferredStyle: .actionSheet)
        let safari = UIAlertAction(title: "Open in Safari", style: .default) { _ in UIApplication.shared.open(url) }
        let webView = UIAlertAction(title: "Open within app", style: .default) { [weak self] _ in
            guard let self = self else { return }

            let detailViewController = HomeDetailViewController(url: url)
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
        alert.addAction(safari)
        alert.addAction(webView)

        present(alert, animated: true)
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
