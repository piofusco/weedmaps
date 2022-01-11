//
// Created by jarvis on 1/11/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol WeedmapsJSONEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: WeedmapsJSONEncoder {}