//
//  RootViewPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/8/31.
//

import Foundation
import UIKit

public protocol RootViewPresenterServiceDowngrade {
    func getService<T>(_ type: T.Type) -> T?
}

public struct RootViewPresenterConfig {
    /// `getService()` downgrade to global services.
    public static var serviceDowngrade: RootViewPresenterServiceDowngrade? = nil
}

public protocol RootViewPresentable: ViewPresentable, NotifyRegistrar {
    /// Root presenter do not has super presenters.
    /// Use this method instead of `func attachSuperPresenter(_ superPresenter: ViewPresentable)`
    func attachSuperPresenter()
    
    /// Root presenter do not has super presenters.
    /// Use this method instead of `func onAttach(presenter: ViewPresentable)`
    func onAttach()
}

/// The root of presenters.
open class RootViewPresenter<View>: IdentifierViewGroupPresenter<View>, RootViewPresentable, ServiceRegistrar {
    
    required public override init() {
        super.init()
        autoBindView = false
    }
    
    private var _viewUpdatePipeline: ViewUpdatePipeline?
    
    @MainActor(unsafe) public lazy var serviceManager = PageServiceManager(provider: nil,
                                                                           notifier: PageServiceManager.Notifier(self))
    public var notifyManager: PageNotifyManager = PageNotifyManager()
    public override var viewUpdatePipeline: ViewUpdatePipeline? { _viewUpdatePipeline }
    
    open override func bindView(_ view: View) {
        _viewUpdatePipeline = ViewUpdatePipelineBuilder.buildDefaultPipeline(presenter: self, view: view as? UIView)
        super.bindView(view)
    }
    
    public override func bindWeakView(_ view: View) {
        _viewUpdatePipeline = ViewUpdatePipelineBuilder.buildDefaultPipeline(presenter: self, view: view as? UIView)
        super.bindWeakView(view)
    }
    
    public override func unbindView() {
        super.unbindView()
        _viewUpdatePipeline?.destroy()
        _viewUpdatePipeline = nil
    }
    
    public override var rootPresenter: RootViewPresentable? { self }
    public override var superPresenter: ViewPresentable? {
        set {  }
        get { nil }
    }
    
    public override func updateViewIfNeeded() {
        _viewUpdatePipeline?.updateViewIfNeeded(synchronize: true)
    }
    
    /// Root presenter do not has super presenters.
    /// Use this method instead of `func onAttach(presenter: ViewPresentable)`
    @MainActor open func onAttach() {
        
    }
    
    @available(*, unavailable)
    public override func onAttach(presenter: ViewPresentable) {
        assert(false, "USE onAttach() instead!")
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
    
    @available(*, unavailable)
    public override func attachSuperPresenter(_ superPresenter: ViewPresentable) {
        assert(false, "USE attachSuperPresenter() instead!")
    }
    
    public override func detachSuperPresenter() {
        super.detachSuperPresenter()
        _hasAttached = false
    }
    
    public override func notify<T>(listener: T.Type, scope: NotifyScope, from: AnyObject?, _ closure: (T) -> Void) {
        switch scope {
        case .global: fallthrough
        case .reusable: fallthrough
        case .children: fallthrough
        case .childrenAndSelf:
            notifyManager.notify(listener: listener, from: from, closure)
            super.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        case .parents:
            notifyManager.notify(listener: listener, from: from, closure)
            super.notify(listener: listener, scope: .parents, from: from, closure)
        }
    }
    
    public override func getService<T>(_ type: T.Type) -> T? {
        if let s = serviceManager.getService(type) {
            return s
        }
        else if let downgrade = RootViewPresenterConfig.serviceDowngrade {
            return downgrade.getService(type)
        }
        return nil
    }
    
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T) {
        serviceManager.register(service: service, lazy: lazy, builder)
    }
    
    
    public func unregister<T>(service: T.Type) {
        serviceManager.unregister(service: service)
    }
    
    @MainActor public func add<T>(listener: T.Type, object: AnyObject) {
        notifyManager.add(listener: listener, object: object)
    }
    
    @MainActor public func remove<T>(listener: T.Type, object: AnyObject) {
        notifyManager.remove(listener: listener, object: object)
    }
    
    public func removeAllListeners(of object: AnyObject) {
        notifyManager.removeAllListeners(of: object)
    }
}
