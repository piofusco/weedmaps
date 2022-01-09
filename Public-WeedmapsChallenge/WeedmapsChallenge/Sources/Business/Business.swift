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
}
