//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import Foundation

struct PageResponse: Decodable {
    let businesses: [Business]
}

struct Business: Decodable {
    let id: String
    let name: String
    let url: String
    let price: String?
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case price
        case imageURL = "image_url"
    }
}
