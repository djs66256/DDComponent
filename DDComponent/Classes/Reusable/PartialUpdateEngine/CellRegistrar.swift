//
//  CellRegistrar.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation
import UIKit

extension Engine {
    @MainActor
    struct UICollectionViewCellRegistrar {
        let collectionView: UICollectionView
        
        init(collectionView: UICollectionView) {
            self.collectionView = collectionView
        }
        
        struct SupplementaryIdentifier: Hashable, Equatable {
            let kind: String
            let identifier: String

            var hashValue: Int {
                var h = Hasher()
                h.combine(kind.hashValue)
                h.combine(identifier.hashValue)
                return h.finalize()
            }

            func hash(into hasher: inout Hasher) {
                kind.hash(into: &hasher)
                identifier.hash(into: &hasher)
            }

            static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.kind == rhs.kind && lhs.identifier == rhs.identifier
            }
        }
        
        private var registered = Set<AnyHashable>()
        
        mutating func dequeueReusableCell(withReuseClass reuseClass: AnyClass, for indexPath: IndexPath) -> UICollectionViewCell {
            let identifier = "\(reuseClass)"
            if !registered.contains(identifier) {
                registered.update(with: identifier)
                collectionView.register(reuseClass, forCellWithReuseIdentifier: identifier)
            }
            return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        }
        
        func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseClass reuseClass: AnyClass, for indexPath: IndexPath) -> UICollectionReusableView {
            let identifer = SupplementaryIdentifier(kind: elementKind, identifier: "\(reuseClass)")
            if !registered.contains(identifer) {
                collectionView.register(reuseClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifer.identifier)
            }
            return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifer.identifier, for: indexPath)
        }
        
        mutating func dequeueReusablePresenter(presenter: CollectionItemReusablePresenterHoldable,
                                               view: UICollectionReusableView,
                                               withReuseClass reuseClass: ReusablePresentable.Type,
                                               for indexPath: IndexPath) -> ReusablePresentable? {
            var reusablePresenter: ReusablePresentable?
            if let p = view.reusablePresenter {
                if let superPresenter = p.superPresenter as? CollectionItemReusablePresenterHoldable {
                    if !superPresenter.tryUnbindReusablePresenter(p) {
                        assert(false, "Unbind reusable presenter failed!")
                    }
                }
                else {
                    // View will be reused, the presenter should not be attached to any super.
                    p.detachSuperPresenter()
                }
                
                p.prepareForReuse()
                
                // Maybe a same view can be reused by different presenter types.
                if type(of: p) == reuseClass {
                    reusablePresenter = p
                }
            }
            if reusablePresenter == nil {
                let p = reuseClass.init()
                view.reusablePresenter = p
                reusablePresenter = p
            }
            
            return reusablePresenter
        }
    }
    
    @MainActor
    struct UITableViewCellRegistrar {
        let tableView: UITableView
        init(tableView: UITableView) {
            self.tableView = tableView
        }
        
        private var registered = Set<AnyHashable>()
        mutating func dequeueCell(withReuseClass reuseClass: AnyClass, for indexPath: IndexPath) -> UITableViewCell {
            let identifier = "\(reuseClass)"
            if !registered.contains(identifier) {
                registered.update(with: identifier)
                tableView.register(reuseClass, forCellReuseIdentifier: identifier)
            }
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        
        private var registeredHeaderFooter = Set<AnyHashable>()
        mutating func dequeueHeaderFooterView(withReuseClass reuseClass: AnyClass) -> UITableViewHeaderFooterView? {
            let identifier = "\(reuseClass)"
            if !registeredHeaderFooter.contains(identifier) {
                registeredHeaderFooter.update(with: identifier)
                tableView.register(reuseClass, forHeaderFooterViewReuseIdentifier: identifier)
            }
            
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        }
        
        mutating func dequeueReusablePresenter(presenter: CollectionItemReusablePresenterHoldable,
                                               view: UIView,
                                               withReuseClass reuseClass: ReusablePresentable.Type) -> ReusablePresentable? {
            var reusablePresenter: ReusablePresentable?
            if let p = view.reusablePresenter {
                if let superPresenter = p.superPresenter as? CollectionItemReusablePresenterHoldable {
                    if !superPresenter.tryUnbindReusablePresenter(p) {
                        assert(false, "Unbind reusable presenter failed!")
                    }
                }
                else {
                    // View will be reused, the presenter should not be attached to any super.
                    p.detachSuperPresenter()
                }
                
                p.prepareForReuse()
                
                // Maybe a same view can be reused by different presenter types.
                if type(of: p) == reuseClass {
                    reusablePresenter = p
                }
            }
            if reusablePresenter == nil {
                let p = reuseClass.init()
                view.reusablePresenter = p
                reusablePresenter = p
            }
            
            return reusablePresenter
        }
    }
    
}


fileprivate extension UIView {
    private static var key = 0
    
    private class AutoUnbind {
        
        let presenter: ReusablePresentable
        
        init(presenter: ReusablePresentable) {
            self.presenter = presenter
        }
        
        deinit {
            let presenter = presenter
            performOnMainActorSync {
                if let superPresenter = presenter.superPresenter as? ReusableViewPresenterHoldable {
                    superPresenter.tryUnbindReusablePresenter(presenter)
                }
                presenter.detachSuperPresenter()
            }
        }
    }
    
    var reusablePresenter: ReusablePresentable? {
        get { (objc_getAssociatedObject(self, &Self.key) as? AutoUnbind)?.presenter }
        set {
            if let newValue {
                objc_setAssociatedObject(self, &Self.key, AutoUnbind(presenter: newValue), .OBJC_ASSOCIATION_RETAIN)
            }
            else {
                objc_setAssociatedObject(self, &Self.key, nil, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
}
