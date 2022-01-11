//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol AutoCompleteDelegate: AnyObject {
    func searchBarDidUpdate(term: String)
    func didSelectTerm(term: String)
}

class AutoCompleteTableViewController: UITableViewController {
    weak var delegate: AutoCompleteDelegate?
    var autoCompleteStrings = [String]()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        autoCompleteStrings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "AutoCompleteCell")
        cell.textLabel?.text = autoCompleteStrings[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectTerm(term: autoCompleteStrings[indexPath.row])
    }
}

extension AutoCompleteTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let term = searchController.searchBar.text, !term.isEmpty else { return }

        delegate?.searchBarDidUpdate(term: term)
    }
}