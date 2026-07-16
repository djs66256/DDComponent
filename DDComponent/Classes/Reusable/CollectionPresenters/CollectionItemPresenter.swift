//
//  CollectionItemPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation
import UIKit

open class CollectionItemPresenter<V: UIView>: CollectionItemReusablePresenterHolder<CollectionItemPresenter.ShadowPresenter, V>
where V: UIView {
    public final class ShadowPresenter: ReusableViewPresenter<V> {
        weak var shadowSource: CollectionItemPresenter<V>?
        
        public override func onBindView(_ view: V) {
            shadowSource?.onBindView(view)
        }
        
        public override func onUnbindView() {
            if let view {
                shadowSource?.onUnbindView(view)
            }
        }
        
        public override func onUpdate(view: V, context: ViewUpdateContext) {
            shadowSource?.onUpdate(view: view, context: context)
        }
    }
    
    public override func setState(updater: () -> Void, context: ((inout ViewUpdateContext) -> Void)? = nil, completion: (() -> Void)? = nil) {
        for p in reusedPresenters {
            p.setState(updater: {}, context: context)
        }
        super.setState(updater: updater, context: context, completion: completion)
    }
    
    public override func dryRunUpdateReusablePresenter(_ presenter: ReusablePresentable) -> Bool {
        guard let p = presenter as? ShadowPresenter else {
            return false
        }
        
        p.shadowSource = self
        return super.dryRunUpdateReusablePresenter(presenter)
    }
    
    open override func onBindReusablePresenter(_ presenter: ShadowPresenter) {
        super.onBindReusablePresenter(presenter)
        presenter.shadowSource = self
    }
    
    open override func onUnbindReusablePresenter(_ presenter: ShadowPresenter) {
        super.onUnbindReusablePresenter(presenter)
        presenter.shadowSource = nil
    }
    
    open func onBindView(_ view: V) {
        
    }
    
    open func onUnbindView(_ view: V) {
        
    }
    
    open func onUpdate(view: V, context: ViewUpdateContext) {
        
    }
    
    // MARK: - deprecated
    
    public final override func onBindView(_ view: ()) {
        super.onBindView(view)
    }
    
    public final override func onUnbindView() {
        super.onUnbindView()
    }
    
    public final override func onUpdate(view: (), context: ViewUpdateContext) {
        
    }
}
