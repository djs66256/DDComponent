//
//  SectionPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/9/13.
//

import Foundation
import UIKit

enum CollectionElementKind { }
// Use the same name for UITableView & UICollectionView
@MainActor extension CollectionElementKind {
    public static let sectionHeader = UICollectionView.elementKindSectionHeader
    public static let sectionFooter = UICollectionView.elementKindSectionFooter
    
}

/// SectionPresenter for view of collection type, like UITableView or UICollectionView.
open class CollectionSectionPresenter: ViewPresenter<Void>, CollectionSectionPresentable {
    
    public convenience init(items: [CollectionItemPresentable]) {
        self.init()
        self.items = items
    }
    
    private var _items: [CollectionItemPresentable] = []
    
    /// Item presenters. Rows in UITableView
    public var items: [CollectionItemPresentable] {
        get { _items }
        set { setItems(newValue) }
    }
    
    public func setItems(_ newValue: [CollectionItemPresentable], animated: Bool = false, completion: (()->Void)? = nil) {
        let oldValue = _items
        _items = newValue
        // Remove old ones from children if not existing in new items.
        let newSet = Set(_items.map({ ObjectIdentifier($0) }))
        for old in oldValue {
            if !newSet.contains(ObjectIdentifier(old)) {
                remove(child: old)
            }
        }
        // Add new items to children, do nothing if already in chidren.
        for item in _items {
            // Only new item needs adding child.
            if item.superPresenter !== self {
                add(child: item)
            }
        }
        setState(updater: {}, context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }, completion: completion)
    }
    
    var _supplementaries: [String: [CollectionItemPresentable]] = [:]
    
    /// Supplementary view presenters. Not available in UITableView, and just for storage of header & footer.
    public var supplementaries: [String: [CollectionItemPresentable]] {
        _supplementaries
    }
    
    /// Set supplementary with kind
    /// - Parameters:
    ///   - kind: Type of supplementary
    ///   - supplementaries: Supplementary view presenters
    ///   - animated: Whether update with animtion.
    public func setSupplementary(_ kind: String,
                                 _ supplementaries: [CollectionItemPresentable]?,
                                 animated: Bool = false,
                                 completion: (()->Void)? = nil) {
        guard let supplementaries = supplementaries else {
            removeSupplementary(kind)
            return
        }

        // Remove old ones from children if not existing in supplementaries
        let newSet = Set(supplementaries.map({ ObjectIdentifier($0) }))
        if let olds = _supplementaries[kind] {
            for old in olds {
                if !newSet.contains(ObjectIdentifier(old)) {
                    remove(child: old)
                }
            }
        }
        // Add new supplementaries to children, do nothing if already in chidren.
        for supplementary in supplementaries {
            // Only new supplementary needs adding child.
            if supplementary.superPresenter !== self {
                add(child: supplementary)
            }
        }
        setState(updater: {
            self._supplementaries[kind] = supplementaries
        }, context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }, completion: completion)
    }
    
    /// Remove supplementary by kind
    /// - Parameter kind: Type of supplementary
    public func removeSupplementary(_ kind: String, animated: Bool = false) {
        if let olds = _supplementaries[kind] {
            for old in olds {
                remove(child: old)
            }
        }
        
        setState {
            self._supplementaries[kind] = nil
        } context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }
    }
    
}

//public extension CollectionSectionPresenter {
//    
//    var header: CollectionItemPresentable? {
//        get {
//            supplementaries[CollectionElementKind.sectionHeader]?.first
//        }
//        set {
//            if let newValue = newValue {
//                setSupplementary(CollectionElementKind.sectionHeader, [newValue])
//            }
//            else {
//                removeSupplementary(CollectionElementKind.sectionHeader)
//            }
//        }
//    }
//    
//    var footer: CollectionItemPresentable? {
//        get {
//            supplementaries[CollectionElementKind.sectionFooter]?.first
//        }
//        set {
//            if let newValue = newValue {
//                setSupplementary(CollectionElementKind.sectionFooter, [newValue])
//            }
//            else {
//                removeSupplementary(CollectionElementKind.sectionFooter)
//            }
//        }
//    }
//}
