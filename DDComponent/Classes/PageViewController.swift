//
//  DDComponent.swift
//  DDComponent
//
//  Created by daniel on 2022/8/30.
//

import Foundation

@MainActor
public protocol PageLifecycle {
    func viewWillAppear(_ animated: Bool)
    
    func viewDidAppear(_ animated: Bool)
    
    func viewWillDisappear(_ animated: Bool)
    
    func viewDidDisappear(_ animated: Bool)
}

open class PageViewController<FrameView: UIView, Presenter, View>: UIViewController,  ServiceRegistrar
    where Presenter: RootViewPresenter<View> {
    
    @MainActor private var _presenter: Presenter!
    @MainActor public var presenter: Presenter {
        get {
            loadPresenterIfNeeded()
            return _presenter
        }
    }
    
    @MainActor public var presenterView: View? {
        loadViewIfNeeded()
        return presenter.view
    }
    
    @MainActor public var frameView: FrameView {
        loadViewIfNeeded()
        return view as! FrameView
    }
    
    deinit {
        if isPresentLoaded {
            performOnMainActorSync {
                self.presenter.detachAllPresentersRecursive()
            }
        }
    }
    
    @MainActor open func makePresenter() -> Presenter {
        Presenter.init()
    }
    
    @MainActor open func makeView() -> FrameView {
        FrameView(frame: UIScreen.main.bounds)
    }
    
    @MainActor open func bindView(_ view: FrameView) {
        if !presenter.tryBindWeakView(view) {
            assert(false, "\(view.debugDescription) does not conform to presenter view type (\(View.self))")
        }
    }
    
    @MainActor public var isPresentLoaded: Bool = false
    @MainActor public func loadPresenterIfNeeded() {
        if !isPresentLoaded {
            isPresentLoaded = true
            _presenter = makePresenter()
            presenterDidLoad()
            _presenter.attachSuperPresenter()
        }
    }
    
    @MainActor open func presenterDidLoad() {
        pageInstallers.install(presenter: presenter)
    }
    
    @MainActor @PageInstallerBuilder open var pageInstallers: PageInstaller {
        NopInstaller()
    }
    
    open override func loadView() {
        view = makeView()
        bindView(view as! FrameView)
    }
    
    // MARK: - PageLifecycle
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notify(listener: PageLifecycle.self) {
            $0.viewWillAppear(animated)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notify(listener: PageLifecycle.self) {
            $0.viewDidAppear(animated)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notify(listener: PageLifecycle.self) {
            $0.viewWillDisappear(animated)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        notify(listener: PageLifecycle.self) {
            $0.viewDidDisappear(animated)
        }
    }

    // MARK: - messages & services
    
    public func getService<T>(_ type: T.Type) -> T? {
        presenter.getService(type)
    }
    
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T) {
        presenter.register(service: service, lazy: lazy, builder)
    }

    public func unregister<T>(service: T.Type) {
        presenter.unregister(service: service)
    }

    public func add<T>(listener: T.Type) {
        presenter.add(listener: listener, object: self)
    }

    public func remove<T>(listener: T.Type) {
        presenter.remove(listener: listener, object: self)
    }

    public func removeAllListeners() {
        presenter.removeAllListeners(of: self)
    }

    public func notify<T>(listener: T.Type, _ closure:(T)->Void) {
        presenter.notifyGlobal(listener: listener, closure)
    }
}


