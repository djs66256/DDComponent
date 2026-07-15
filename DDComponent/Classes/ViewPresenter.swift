//
//  ViewPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/8/31.
//

import Foundation

public protocol ViewPresenterExtensionKey {
    associatedtype ValueType
    static func create(by presenter: ViewPresentable) -> ValueType
}

/// View presenter type, for type-erase usage.
@MainActor
public protocol ViewPresentable: ViewPresenterNotifiable, ServiceProvider {
    
    var hasBoundView: Bool { get }
    
    /// Get binded view
    var anyView: Any? { get }
    
    /// After `setState`, update pipeline will call `updateViewIfNeeded` at sometime.
    /// Then should update view changes, and call `onUpdate(view:)`.
    /// You should never override this yourself.
    /// Notice: update view of this presenter only, but update all view-tree when is root presenter.
    func updateViewIfNeeded()
    
    /// When any `setState` has set `context.invalidateLayout = true`, it will call this method.
    /// It used for custom invalidate layout, and if View is UIView, `view.setNeedsUpdate()` is default implement.
    /// You should override it if any custom layout. For example, when `UICollectionView`, it should be
    /// `collectionView.collectionViewLayout.invalidateLayout()`
    func invalidateLayout()
    
    /// Force layout subviews. If view is UIView, `view.updateConstraintsIfNeeded() view.layoutIfNeeded` will called.
    /// You should override it if any custom layout.
    func layoutIfNeeded()
    
    /// Try to bind a view, if view is not the right type, it will do nothing.
    /// It will call `onBindView(_:)` if success bind view.
    /// - Returns: Bind result, false means can not bind this view.
    func tryBindView(_ view: Any) -> Bool
    
    /// The same as `tryBindView(_ view: Any) -> Bool`, but will store view by weak reference.
    /// - Returns: Bind result
    func tryBindWeakView(_ view: AnyObject) -> Bool
    
    var autoBindView: Bool { get }
    var autoBindChildrenPresenterViews: Bool { get }
    func tryAutoBindView()
    
    /// Unbind view, do nothing if not bind any view.
    /// It will call `onUnbindView()` if success unbind view.
    func unbindView()
    
    var superPresenter: ViewPresentable? { get }
    
    var children: [ViewPresentable] { get }
    func add(child: ViewPresentable)
    func remove(child: ViewPresentable)
    func removeAllChildrenPresenter()
    func removeFromSuper()
    
    // for internal usage
    
    /// Detach all presenters when deinit.
    func detachAllPresentersRecursive()
    
    /// Attach to super presenter, when added to super presenter.
    func attachSuperPresenter(_ superPresenter: ViewPresentable)
    func detachSuperPresenter()
    
    var rootPresenter: RootViewPresentable? { get }
    
    func attachRootPresenter(_ rootPresenter: RootViewPresentable)
    func detachRootPresenter()
    
    /// Pipeline will call this to real update view
    func updateView(context: ViewUpdateContext)
    func updateViewWithoutLayout(context: ViewUpdateContext)
    var viewUpdatePipeline: ViewUpdatePipeline? { get }
    
    func extensionObject<T: ViewPresenterExtensionKey>(for key: T) -> T.ValueType
    func extensionObject<T: ViewPresenterExtensionKey>(for key: T, createIfNeeded: Bool) -> T.ValueType?
}

/// Default Hashable implement. As presenter is unique, so we use the pointer to identify.
extension ViewPresentable {
    public nonisolated var hashValue: Int {
        ObjectIdentifier(self).hashValue
    }
    public nonisolated func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}

fileprivate var defaultContext = ViewUpdateContext()

@MainActor public func performBatchUpdate(_ updater: () -> Void,
                                          context: (inout ViewUpdateContext) -> Void) {
    let backup = defaultContext
    var copy = defaultContext
    context(&copy)
    defaultContext = copy
    updater()
    defaultContext = backup
}

/// Base class of all presenters.
@MainActor
open class ViewPresenter<View>: ViewPresentable {

    public init() {}
    
    private var _view: (()->View?)?
    public var view: View? { _view?() }
    public var anyView: Any? {
        view
    }
    
    // MARK: - Lifecycle for override
    
    /// Attached to a super presenter
    /// - Parameter presenter: super presenter
    open func onAttach(presenter: ViewPresentable) { }
    
    /// Will detach from super presenter
    open func onDetach() { }
    
    open func onAttachToRoot(rootPresenter: RootViewPresentable) {
        for effect in effects {
            effect.onAttach()
        }
    }
    
    open func onDetachFromRoot() {
        for effect in effects {
            effect.onDetach()
        }
    }
    
    /// Binded a new view
    /// - Parameter view: view to bind
    open func onBindView(_ view: View) { }
    
    /// Will unbind view
    open func onUnbindView() { }
    
    /// All view updaters in this method, it will called because state changed by `setState`
    /// - Parameters:
    ///   - view: binded view
    ///   - context: this update action context, you should rarely need this
    open func onUpdate(view: View, context: ViewUpdateContext) {
        for updater in updaters {
            updater.update(view: view, context: context)
        }
    }
    
    /// After `setState`, update pipeline will call `updateViewIfNeeded` at sometime.
    /// Then should update all view changes, and call `onUpdate(view:)`.
    /// You should never override this yourself.
    public func updateViewIfNeeded() {
        viewUpdatePipeline?.updateViewPresenterIfNeeded(self)
    }

    /// State changed, will perform update view at sometime future.
    /// - Parameters:
    ///   - updater: The updater to update state of this presenter.
    ///   - context: The context of this update action.
    ///   - completion: Called when update completion, after animation completion if animated.
    public func setState(updater: ()->Void,
                         context: ((inout ViewUpdateContext)->Void)? = nil,
                         completion: (() -> Void)? = nil) {
        var ctx = defaultContext
        context?(&ctx)
        
        needsUpdate = true
        StateContext.beginUpdate()
        updater()
        StateContext.endUpdate()
        
        if let viewUpdatePipeline {
            commitTransactionBeforeBindViewIfNeeded()
            viewUpdatePipeline.markDirty(presenter: self, context: ctx, completion)
            if ctx.updateViewImmediately {
                updateViewIfNeeded()
            }
        }
        else {
            saveTransactionBeforeBindViewIfNeeded(context: ctx, completion: completion)
        }
    }

    public class Updater {
        var updater: @MainActor (View, ViewUpdateContext) -> Void
        var dispose: (@MainActor () -> Void)?

        init(
            updater: @escaping (View, ViewUpdateContext) -> Void,
            dispose: (() -> Void)? = nil
        ) {
            self.updater = updater
            self.dispose = dispose
        }

        @MainActor func update(view: View, context: ViewUpdateContext) {
            updater(view, context)
        }

        @MainActor public func cancel() {
            dispose?()
            dispose = nil
        }

        deinit {
            if let dispose {
                performOnMainActorAsync {
                    dispose()
                }
            }
        }

        static func == (lhs: Updater, rhs: Updater) -> Bool {
            lhs === rhs
        }
    }
    var updaters = [Updater]()

    public class Effect {
        private var action: @MainActor () -> (@MainActor () -> Void)?
        private var cancelAction: (@MainActor () -> Void)?
        var dispose: (() -> Void)?
        init(action: @escaping @MainActor () -> (@MainActor () -> Void)?) {
            self.action = action
        }

        @MainActor func onAttach() {
            cancelAction = action()
        }

        @MainActor func onDetach() {
            cancelAction?()
            cancelAction = nil
        }

        @MainActor public func cancel() {
            cancelAction?()
            cancelAction = nil
            dispose?()
            dispose = nil
        }

        deinit {
            let cancelAction = cancelAction
            let dispose = dispose
            performOnMainActorAsync {
                cancelAction?()
                dispose?()
            }
        }
    }

    var effects = [Effect]()

    @MainActor
    private class BeforeBindViewUpdateTransaction {
        var context: ViewUpdateContext
        var completions: [() -> Void] = []
        
        init(context: ViewUpdateContext, completion: (() -> Void)?) {
            self.context = context
            self.completions = { if let completion { return [completion] } else { return [] } }()
        }
        
        func merge(_ other: BeforeBindViewUpdateTransaction) {
            self.context.merge(other.context)
            self.completions.append(contentsOf: other.completions)
        }
        
        func complete() {
            for completion in completions {
                completion()
            }
        }
    }
    
    private var transactionBeforeBindView: BeforeBindViewUpdateTransaction?
    
    @MainActor func saveTransactionBeforeBindViewIfNeeded(context: ViewUpdateContext, completion: (() -> Void)?) {
        let transaction = BeforeBindViewUpdateTransaction(context: context, completion: completion)
        if let transactionBeforeBindView {
            transactionBeforeBindView.merge(transaction)
        }
        else {
            self.transactionBeforeBindView = transaction
        }
    }
    
    @MainActor func commitTransactionBeforeBindViewIfNeeded() {
        if let viewUpdatePipeline, let transactionBeforeBindView {
            viewUpdatePipeline.markDirty(presenter: self,
                                         context: transactionBeforeBindView.context,
                                         { transactionBeforeBindView.complete() })
            self.transactionBeforeBindView = nil
        }
    }
    
    // MARK: - View
    
    /// Whether is any view binded.
    public var hasBoundView: Bool {
        _view != nil
    }
    
    /// Try to bind a view, if view is not the right type, it will do nothing.
    /// It will call `onBindView(_:)` if success bind view.
    /// - Returns: Bind result, false means can not bind this view.
    public func tryBindView(_ view: Any) -> Bool {
        if let view = view as? View {
            bindView(view)
            return true
        }
        return false
    }
    
    /// The same as `tryBindView(_ view: Any) -> Bool`, but will store view by weak reference.
    /// - Returns: Bind result
    public func tryBindWeakView(_ view: AnyObject) -> Bool {
        if let view = view as? View {
            bindWeakView(view)
            return true
        }
        return false
    }
    
    /// Auto bind view if true.
    public var autoBindView: Bool = true
    public var autoBindChildrenPresenterViews: Bool = true
    
    public func tryAutoBindView() {
        guard let superPresenter = superPresenter, autoBindView, view == nil else {
            return
        }
        
        if View.self == Void.self {
            bindView(() as! View)
        }
        else if let view: View = ViewAutoBinder().findChildView(presenter: superPresenter) {
            bindView(view)
        }
    }
    
    /// Bind a view.
    /// - Parameter view: view to bind
    public func bindView(_ view: View) {
        if hasBoundView {
            unbindView()
        }
        _view = { view }
        onBindView(view)
        // Auto bind child presenter and view
        if autoBindChildrenPresenterViews {
            for child in children {
                child.tryAutoBindView()
            }
        }
        // update view when first binded
        setState { } context: { $0.bindView() }
    }
    
    /// Bind a weak view.
    /// - Parameter view: view to bind
    public func bindWeakView(_ view: View) {
        let obj = view as AnyObject
        if hasBoundView {
            unbindView()
        }
        _view = { [weak obj] in obj as? View }
        onBindView(view)
        // Auto bind child presenter and view
        if autoBindChildrenPresenterViews {
            for child in children {
                child.tryAutoBindView()
            }
        }
        // update view when first binded
        setState { } context: { $0.bindView() }
    }
    
    /// Unbind view, do nothing if not bind any view.
    /// It will call `onUnbindView()` if success unbind view.
    public func unbindView() {
        if hasBoundView {
            onUnbindView()
            for child in children {
                child.unbindView()
            }
            _view = nil
        }
    }
    
    // MARK: - Presenter-Tree
    
    var _children = [ViewPresentable]()
    public var children: [ViewPresentable] { _children }
    public internal(set) weak var superPresenter: ViewPresentable?
    
    /// Add a child presenter to this presenter.
    /// - Parameter child: child presenter to be added
    public func add(child: ViewPresentable) {
        // TODO: optimize contains()
        if let sp = child.superPresenter {
            if sp == self {
                // Move to the last position
                _children.removeAll(where: { $0 == child })
                _children.append(child)
            }
            else {
                child.removeFromSuper()
                _children.append(child)
                child.attachSuperPresenter(self)
            }
        }
        else {
            _children.append(child)
            child.attachSuperPresenter(self)
        }
    }
    
    /// Remove a child presenter from this presenter.
    /// - Parameter child: child presenter to be removed
    public func remove(child: ViewPresentable) {
        if let sp = child.superPresenter, sp == self {
            child.detachSuperPresenter()
            _children.removeAll(where: { $0 == child })
        }
    }
    
    /// Remove all children presenter
    public func removeAllChildrenPresenter() {
        for child in children {
            child.detachSuperPresenter()
        }
        _children.removeAll()
    }
    
    /// Remove from super presenter if added to a super persenter.
    public func removeFromSuper() {
        if let presenter = superPresenter {
            presenter.remove(child: self)
        }
    }
    
    public func detachAllPresentersRecursive() {
        for child in children {
            child.detachAllPresentersRecursive()
        }
        _children.removeAll()
        
        detachSuperPresenter()
    }
    
    public var hasAttached: Bool {
        superPresenter != nil
    }
    
    public var hasAttachedRoot: Bool {
        rootPresenter != nil
    }
    
    public func attachSuperPresenter(_ superPresenter: ViewPresentable) {
        if hasAttached {
            detachSuperPresenter()
        }
        
        self.superPresenter = superPresenter
        onAttach(presenter: superPresenter)
        
        if let rootPresenter = superPresenter.rootPresenter {
            attachRootPresenter(rootPresenter)
        }
        
        if superPresenter.hasBoundView, superPresenter.autoBindChildrenPresenterViews {
            tryAutoBindView()
        }
    }
    
    public func detachSuperPresenter() {
        if hasBoundView {
            unbindView()
        }
        
        if hasAttached {
            onDetach()
        }
        
        detachRootPresenter()
        
        superPresenter = nil
    }
    
    
    public private(set) weak var rootPresenter: RootViewPresentable? = nil
    
    public func attachRootPresenter(_ rootPresenter: RootViewPresentable) {
        self.rootPresenter = rootPresenter
        onAttachToRoot(rootPresenter: rootPresenter)
        for child in children {
            child.attachRootPresenter(rootPresenter)
        }
    }
    
    public func detachRootPresenter() {
        if hasAttachedRoot {
            for child in children {
                child.detachRootPresenter()
            }
            onDetachFromRoot()
            rootPresenter = nil
        }
    }
    
    // MARK: - Update pipeline
    
    /// Update pipeline, dicide how to update view.
    public var viewUpdatePipeline: ViewUpdatePipeline? {
        superPresenter?.viewUpdatePipeline
    }
    
    private var needsUpdate = true
    public func updateView(context: ViewUpdateContext) {
        if needsUpdate {
            doUpdate(context: context)
            needsUpdate = false
        }
    }
    
    public func updateViewWithoutLayout(context: ViewUpdateContext) {
        if needsUpdate {
            doUpdate(layoutImmediately: false, context: context)
            needsUpdate = false
        }
    }
    
    func doUpdate(layoutImmediately: Bool = true, context: ViewUpdateContext) {
        if let view = view {
            onUpdate(view: view, context: context)
            if context.invalidateConstraints {
                invalidateConstraints()
            }
            if context.invalidateLayout {
                invalidateLayout()
            }
            if context.layoutImmediately && layoutImmediately {
                layoutIfNeeded()
            }
        }
    }
    
    open func invalidateConstraints() {
        (view as? UIView)?.setNeedsUpdateConstraints()
    }
    
    open func invalidateLayout() {
        (view as? UIView)?.setNeedsLayout()
        superPresenter?.invalidateLayout()
    }
    
    open func layoutIfNeeded() {
        (view as? UIView)?.updateConstraintsIfNeeded()
        superPresenter?.layoutIfNeeded()
        (view as? UIView)?.layoutIfNeeded()
    }
    
    // MARK: - messages & services
    open func notify<T>(listener: T.Type, scope: NotifyScope, from: AnyObject?, _ closure: (T) -> Void) {
        switch scope {
        case .global:
            rootPresenter?.notify(listener: listener, scope: scope, from: from, closure)
        case .reusable:
            // Let super presenter to determine which one is reusable presenter
            superPresenter?.notify(listener: listener, scope: scope, from: from, closure)
        case .children:
            _notifyChildren(listener: listener, from: from, closure)
        case .childrenAndSelf:
            _notifyChildrenAndSelf(listener: listener, from: from, closure)
        case .parents:
            _notifyParents(listener: listener, from: from, closure)
        }
    }
    
    private func _notifyChildren<T>(listener: T.Type, from: AnyObject?, _ closure: (T) -> Void) {
        for child in children {
            child.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        }
    }
    
    private func _notifyChildrenAndSelf<T>(listener: T.Type, from: AnyObject?, _ closure:(T)->Void) {
        if let obj = self as? T, self !== from {
            closure(obj)
        }
        for child in children {
            child.notify(listener: listener, scope: .childrenAndSelf, from: from, closure)
        }
    }
    
    private func _notifyParents<T>(listener: T.Type, from: AnyObject?, _ closure: (T) -> Void) {
        if let responder = self as? T, self !== from {
            closure(responder)
        }
        superPresenter?.notify(listener: listener, scope: .parents, from: from, closure)
    }
    
    @MainActor(unsafe) open func getService<T>(_ type: T.Type) -> T? {
        superPresenter?.getService(type)
    }
    
    private lazy var extensionObjects: [ObjectIdentifier: Any] = [:]
    public func extensionObject<T: ViewPresenterExtensionKey>(for key: T) -> T.ValueType {
        let key = ObjectIdentifier(T.self)
        if let value = extensionObjects[key] as? T.ValueType {
            return value
        }
        else {
            let value = T.create(by: self)
            extensionObjects[key] = value
            return value
        }
    }
    
    public func extensionObject<T: ViewPresenterExtensionKey>(for key: T, createIfNeeded: Bool) -> T.ValueType? {
        if createIfNeeded {
            return extensionObject(for: key)
        }
        else {
            return extensionObjects[ObjectIdentifier(T.self)] as? T.ValueType
        }
    }
}


@inlinable
public func == (lhs: ViewPresentable, rhs: AnyObject) -> Bool {
    (lhs as AnyObject) === rhs
}
@inlinable
public func != (lhs: ViewPresentable, rhs: AnyObject) -> Bool {
    (lhs as AnyObject) !== rhs
}
@inlinable
public func == (lhs: ViewPresentable, rhs: ViewPresentable) -> Bool {
    lhs === rhs
}
@inlinable
public func != (lhs: ViewPresentable, rhs: ViewPresentable) -> Bool {
    lhs !== rhs
}
@inlinable
public func == <P:ViewPresenter<V>, V> (lhs: ViewPresentable, rhs: P) -> Bool {
    lhs == (rhs as ViewPresentable)
}
@inlinable
public func != <P:ViewPresenter<V>, V> (lhs: ViewPresentable, rhs: P) -> Bool {
    lhs != (rhs as ViewPresentable)
}
@inlinable
public func == <P1:ViewPresenter<V1>, P2:ViewPresenter<V2>, V1, V2> (lhs: P1, rhs: P2) -> Bool {
    (lhs as ViewPresentable) == (rhs as ViewPresentable)
}
@inlinable
public func != <P1:ViewPresenter<V1>, P2:ViewPresenter<V2>, V1, V2> (lhs: P1, rhs: P2) -> Bool {
    !(lhs == rhs)
}

@MainActor(unsafe) @preconcurrency
func performOnMainActorSync(_ closure: @MainActor @escaping ()->Void) {
    if Thread.isMainThread {
        return closure()
    }
    else {
        DispatchQueue.main.sync(execute: closure)
    }
}

func performOnMainActorAsync(_ closure: @MainActor @escaping ()->Void) {
//    if Thread.isMainThread {
//        closure()
//    }
//    else {
        DispatchQueue.main.async(execute: closure)
//    }
}

@MainActor
fileprivate struct StateContext {
    private static var setStateCount: Int = 0
    static var isUpdating: Bool {
        setStateCount != 0
    }
    static func beginUpdate() {
        setStateCount += 1
    }
    static func endUpdate() {
        setStateCount -= 1
    }
}

/// A checker to make sure state value MUST be updated inside of setState{}
@propertyWrapper
@MainActor public struct StateChecker<T> {
    public var wrappedValue: T {
        willSet {
            assert(StateContext.isUpdating, "MUST update state value inside of setState{} !")
        }
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
