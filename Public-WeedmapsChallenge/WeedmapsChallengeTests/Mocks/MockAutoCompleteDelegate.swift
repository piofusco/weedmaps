//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

@testable import WeedmapsChallenge

class MockAutoCompleteDelegate: AutoCompleteDelegate {
    var lastSearchedTerm: String?

    func searchBarDidUpdate(term: String) {
        lastSearchedTerm = term
    }

    var lastSelectedTerm: String?

    func didSelectTerm(term: String) {
        lastSelectedTerm = term
    }
}
