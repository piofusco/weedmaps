//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol AutoCompleteDelegate: AnyObject {
    func didSelectTerm(term: String)
}

class AutoCompleteTableViewController: UITableViewController {
    var autoCompleteStrings = [String]()
    var previousSearches = [String]()
    var displayPreviousSearches = true

    weak var delegate: AutoCompleteDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayPreviousSearches {
            return previousSearches.count
        } else {
            return autoCompleteStrings.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "AutoCompleteCell")
        cell.textLabel?.text = displayPreviousSearches ? previousSearches[indexPath.row] : autoCompleteStrings[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if displayPreviousSearches {
            delegate?.didSelectTerm(term: previousSearches[indexPath.row])
        } else {
            delegate?.didSelectTerm(term: autoCompleteStrings[indexPath.row])
        }
    }
}
