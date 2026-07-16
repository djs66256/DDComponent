//
//  UICollectionViewSectionPresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/9/22.
//

import Foundation
import UIKit

/// SectionPresenter for UICollectionView
public protocol UICollectionSectionPresentable: CollectionSectionPresentable {
    
}

/// Config flow layout for section
public struct UICollectionViewFlowSectionLayoutInfo: UICollectionViewLayoutInfo {
    public var inset: UIEdgeInsets = .zero
    public var lineSpacing: CGFloat = 0
    public var itemSpacing: CGFloat = 0
    public var columnCount: Int = 1
    public init() {}
}

public protocol UICollectionViewFlowSectionPresentable: UICollectionSectionPresentable {
    var layoutInfo: UICollectionViewFlowSectionLayoutInfo { get }
}

/// SectionPresenter for UICollectionView with flow layout.
open class UICollectionViewFlowSectionPresenter: CollectionSectionPresenter, UICollectionViewFlowSectionPresentable {
    public var layoutInfo = UICollectionViewFlowSectionLayoutInfo()
}

public extension UICollectionViewFlowSectionPresenter {
    
    var header: UICollectionViewItemPresentable? {
        get {
            supplementaries[CollectionElementKind.sectionHeader]?.first as? UICollectionViewItemPresentable
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionHeader, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionHeader)
            }
        }
    }
    
    var footer: UICollectionViewItemPresentable? {
        get {
            supplementaries[CollectionElementKind.sectionFooter]?.first as? UICollectionViewItemPresentable
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionFooter, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionFooter)
            }
        }
    }
}
