//
//  UICollectionViewPresentable+FlowLayout.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation

public protocol UICollectionViewLayoutInfo { }

// MARK: - Helper
public extension UICollectionViewLayoutInfo {
    mutating func apply(_ closure: (inout Self)->Void) {
        closure(&self)
    }
}
