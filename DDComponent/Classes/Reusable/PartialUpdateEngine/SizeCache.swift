//
//  SizeCache.swift
//  DDComponent
//
//  Created by daniel on 2022/9/23.
//

import Foundation

class SizeCache {
    var cache: [ObjectIdentifier: CGSize] = [:]
    
    subscript(_ key: ViewPresentable) -> CGSize? {
        get { cache[ObjectIdentifier(key)] }
        set { cache[ObjectIdentifier(key)] = newValue }
    }
    
    func clearCache() {
        cache.removeAll()
    }
}
