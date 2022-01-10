//
// Created by jarvis on 1/10/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol MainQueue {
    func async(_ work: @escaping @convention(block) () -> Void)
}

class WeedmapsMainQueue: MainQueue {
    func async(_ work: @escaping @convention(block) () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
}