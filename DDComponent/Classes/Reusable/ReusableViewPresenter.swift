//
//  ReusableViewPresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/5/16.
//

import Foundation
import UIKit

public protocol ReusableViewPresenterHoldable: ViewPresentable {
    var presenterClass: ReusablePresentable.Type { get }
    func tryBindReusablePresenter(_ presenter: ViewPresentable) -> Bool
    func tryUnbindReusablePresenter(_ presenter: ViewPresentable) -> Bool
    
    @available(*, deprecated, message: "Use tryUnbindReusablePresenter(_ presenter:) instead")
    func unbindReusablePresenter()
}

open class ReusableViewPresenterHolder<P, V>: ViewPresenter<()>, ReusableViewPresenterHoldable
    where P: ReusableViewPresenter<V> {
    
    public override init() {
        super.init()
        
        autoBindChildrenPresenterViews = false
    }
    
    public var presenterClass: ReusablePresentable.Type {
        P.self
    }
    
    @available(*, deprecated, message: "Use presenters instead")
    public var presenter: P? {
        reusedPresenters.first
    }
    
    public private(set) var reusedPresenters: [P] = []

    // Cell should not call super layoutIfNeeded()
    open override func layoutIfNeeded() {
        (view as? UIView)?.updateConstraintsIfNeeded()
        (view as? UIView)?.layoutIfNeeded()
    }

    open func onBindReusablePresenter(_ presenter: P) {
        
    }
    
    open func onUpdate(presenter: P, context: ViewUpdateContext) {
        
    }
    
    @available(*, deprecated, message: "Use onUnbindReusablePresenter(_ presenter: P) instead")
    open func onUnbindReusablePresenter() { }
    
    open func onUnbindReusablePresenter(_ presenter: P) {
        
    }
    
    open override func onUnbindView() {
        super.onUnbindView()
        
        // When unbind view, unbind all reused presenters.
        unbindAllReusablePresenters()
    }
    
    public func tryBindReusablePresenter(_ presenter: ViewPresentable) -> Bool {
        if let p: P = presenter as? P {
            if reusedPresenters.contains(where: { $0 == presenter }) {
                assert(false, "Cannot bind reusable presenter tiwce.")
                return false
            }
            bindReusablePresenter(p)
            return true
        }
        return false
    }
    
    public func bindReusablePresenter(_ presenter: P) {
        presenter.removeFromSuper()
        add(child: presenter)
        reusedPresenters.append(presenter)
        
        onBindReusablePresenter(presenter)
        
        // When bind presenter, update presenter immedately, donot need setState().
        var context = ViewUpdateContext()
        context.bindView()
        onUpdate(presenter: presenter, context: context)
    }
    
    public func tryUnbindReusablePresenter(_ presenter: ViewPresentable) -> Bool {
        if let p: P = presenter as? P,
           reusedPresenters.contains(where: { $0 == presenter }) {
            unbindReusablePresenter(p)
            return true
        }
        return false
    }
    
    @available(*, deprecated, message: "Use onUnbindReusablePresenter(_ presenter: P) instead")
    public func unbindReusablePresenter() {
        fatalError("Deprecated")
    }
    
    public func unbindReusablePresenter(_ presenter: P) {
        onUnbindReusablePresenter(presenter)
        remove(child: presenter)
        reusedPresenters.removeAll(where: { $0 == presenter })
    }
    
    public func unbindAllReusablePresenters() {
        for reusedPresenter in reusedPresenters {
            onUnbindReusablePresenter(reusedPresenter)
            remove(child: reusedPresenter)
        }
        reusedPresenters.removeAll()
    }
    
    public override func setState(updater: () -> Void,
                                  context: ((inout ViewUpdateContext) -> Void)? = nil,
                                  completion: (() -> Void)? = nil) {
        needsUpdatePresenter = true
        super.setState(updater: updater, context: context, completion: completion)
    }
    
    private var needsUpdatePresenter: Bool = false
    public override func updateView(context: ViewUpdateContext) {
        updateReusablePresenter(context: context)
        super.updateView(context: context)
    }

    public override func updateViewWithoutLayout(context: ViewUpdateContext) {
        updateReusablePresenter(context: context)
        super.updateViewWithoutLayout(context: context)
    }

    public func updateReusablePresenterIfNeeded() {
        updateViewIfNeeded()
    }
    
    public func updateReusablePresenter(context: ViewUpdateContext) {
        if needsUpdatePresenter {
            doUpdatePresenter(context: context)
            needsUpdatePresenter = false
        }
    }
    
    private func doUpdatePresenter(context: ViewUpdateContext) {
        for presenter in reusedPresenters {
            onUpdate(presenter: presenter, context: context)
        }
    }
    
    public override func notify<T>(listener: T.Type, scope: NotifyScope, from: AnyObject?, _ closure: (T) -> Void) {
        if scope == .reusable {
            // Notify scope in reuseable presenter, just notify bound presenter of it.
            self.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        }
        else {
            super.notify(listener: listener, scope: scope, from: from, closure)
        }
    }
}


public protocol ReusablePresentable: ViewPresentable {
    init()
    func prepareForReuse()
}

open class ReusableViewPresenter<View>: ViewPresenter<View>, ReusablePresentable {
    required public override init() {
        super.init()
        autoBindView = false
    }
    open func prepareForReuse() {
        
    }
}
