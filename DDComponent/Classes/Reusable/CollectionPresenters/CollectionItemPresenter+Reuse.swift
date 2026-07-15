//
//  CollectionItemPresenter+Reuse.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation

public protocol CollectionItemReusablePresenterHoldable: ReusableViewPresenterHoldable, CollectionItemPresentable {
    
    func dryRunUpdateReusablePresenter(_ presenter: ReusablePresentable) -> Bool
    
    func unbindRemovedReusablePresenter()
    /// Run updating view for calculation, not real udpating.
    /// - Returns: If true, run success.
//    func dryRunUpdatingView(_ presenter: ViewPresentable, _ view: UIView, _ context: ViewUpdateContext) -> Bool
}

open class CollectionItemReusablePresenterHolder<P, V>: ReusableViewPresenterHolder<P, V>, CollectionItemReusablePresenterHoldable
where V: UIView, P: ReusablePresentable, P: ReusableViewPresenter<V> {
    
    public var itemClass: UIView.Type {
        V.self
    }
    
    public func dryRunUpdateReusablePresenter(_ presenter: ReusablePresentable) -> Bool {
        if let presenter = presenter as? P {
            onUpdate(presenter: presenter, context: .dryRun)
            return true
        }
        return false
    }
    
    public func unbindRemovedReusablePresenter() {
        var presenters = reusedPresenters
        for presenter in presenters {
            if presenter.view?.superview == nil {
                unbindReusablePresenter(presenter)
            }
        }
    }
}
