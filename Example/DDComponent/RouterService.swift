//
//  RouterService.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/1.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

protocol RouterService {
    func open(route: String) -> Bool
}

class RouterServiceImpl: RouterService {
    func open(route: String) -> Bool {
        print("Open \(route)")
        return true
    }
}
