//
//  CompositeViewPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/9/20.
//

import Foundation
import UIKit

/// Used when without root presenter.
/// When a ViewPresenter migrate to a place not using PagePrensenter, it's helpful with `IsolatedViewPresenter`.
/// It bind real view and its presenter, and can be used isolately without add to any super presenter, but also
/// can perform as a common ViewPresenter added to a super presenter.
/// ```swift
/// let praisePrenster = IsolatedViewPresenter(MyPraiseButton(), MyPraisePresenter())
/// addChildView(praisePrenster.view)
/// ```
@MainActor
public final class IsolatedViewPresenter<UI, P, V>: ManagedViewPresenter<UI>, RootViewPresentable
where P : ViewPresenter<V>, UI: UIView {
    
    public let presenter: P
    
    /// Bind view & presenter, view MUST implement Presenter.View
    /// - Parameters:
    ///   - view: The real UIView that can add to superview, MUST implement Presenter.View
    ///   - presenter: The presenter that bind the view.
    public init(view: UI, presenter: P) {
        assert(view is V)
        self.presenter = presenter
        super.init()
        
        add(child: presenter)
        if !presenter.tryBindView(view) {
            assert(false, "UIView \(UI.self) MUST implement type \(V.self)")
        }
    }
    
    private lazy var _viewUpdatePipeline: ViewUpdatePipeline = ViewUpdatePipelineBuilder.buildDefaultPipeline(presenter: self, view: view)
    
    public let notifyManager: PageNotifyManager = PageNotifyManager()
    public override var viewUpdatePipeline: ViewUpdatePipeline? {
        if superPresenter == nil {
            return _viewUpdatePipeline
        }
        // When added to super presenter, use the root presenter's pipeline
        return super.viewUpdatePipeline
    }
    
    public override func updateViewIfNeeded() {
        _viewUpdatePipeline.updateViewIfNeeded(synchronize: true)
    }
    
    public override func notify<T>(listener: T.Type, scope: NotifyScope, from: AnyObject?, _ closure: (T) -> Void) {
        notifyManager.notify(listener: listener, from: from, closure)
        super.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
    }
    
    public override var rootPresenter: RootViewPresentable? {
        self;
    }
    
    var _hasAttached: Bool = false
    public override var hasAttached: Bool {
        _hasAttached
    }
    
    /// Root presenter do not has super presenters.
    /// Use this method instead of `func attachSuperPresenter(_ superPresenter: ViewPresentable)`
    @MainActor public func attachSuperPresenter() {
        _hasAttached = true
        onAttach()
    }
    
    /// Root presenter do not has super presenters.
    /// Use this method instead of `func onAttach(presenter: ViewPresentable)`
    @MainActor public func onAttach() {
        
    }
    
    public func add<T>(listener: T.Type, object: AnyObject) {
        notifyManager.add(listener: listener, object: object)
    }
    
    public func remove<T>(listener: T.Type, object: AnyObject) {
        notifyManager.remove(listener: listener, object: object)
    }
    
    public func removeAllListeners(of object: AnyObject) {
        notifyManager.removeAllListeners(of: object)
    }
}
