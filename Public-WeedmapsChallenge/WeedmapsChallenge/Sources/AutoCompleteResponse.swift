//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

struct AutoCompleteResponse: Decodable {
    let categories: [AutoCompleteCategory]
    let businesses: [AutoCompleteBusiness]
    let terms: [AutoCompleteTerm]
}

struct AutoCompleteCategory: Decodable {
    let title: String
}

struct AutoCompleteBusiness: Decodable {
    let id: String
    let name: String
}

struct AutoCompleteTerm: Decodable {
    let text: String
}