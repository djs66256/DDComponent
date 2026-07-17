//
//  ViewGroupPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/8/31.
//

import Foundation
import UIKit

@MainActor
public final class ViewPresenterIdentifierStore {
    fileprivate var presenterBuilders: [AnyHashable: ()->ViewPresentable] = [:]
    fileprivate var presenters: [AnyHashable: ViewPresentable] = [:]
    public init() { }
}

@MainActor
public protocol ViewPresenterIdentify: AnyObject {
    var presenterStore: ViewPresenterIdentifierStore { get }
}

public extension ViewPresenterIdentify where Self : ViewPresentable {
    
    /// Register the presenter with a key by lazy.
    /// - Returns: The key of the presenter registered.
    func setLazyViewPresenter<P, V>(_ key: AnyHashable, _ value: @escaping ()->P) where P: ViewPresenter<V> {
        presenterStore.presenterBuilders[key] = { value() }
    }
    
    /// Register the presenter with a key.
    /// - Returns: The key of the presenter registered.
    func setViewPresenter<P, V>(_ key: AnyHashable, _ value: P) where P: ViewPresenter<V> {
        presenterStore.presenters[key] = value
        add(child: value)
    }
    
    /// Register the presenter with a key.
    /// - Returns: The key of the presenter registered.
    func setViewPresenter(_ key: AnyHashable, _ value: ViewPresentable) {
        presenterStore.presenters[key] = value
        add(child: value)
    }
    
    /// Get the presenter registered by the key.
    /// - Returns: The key of the presenter registered.
    func getViewPresenter(_ key: AnyHashable) -> ViewPresentable? {
        if let p = presenterStore.presenters[key] {
            return p
        }
        else {
            if let gen = presenterStore.presenterBuilders[key] {
                let p = gen()
                setViewPresenter(key, p)
                return p
            }
        }
        return nil
    }
    
    /// Get the presenter registered by the key.
    /// - Returns: The key of the presenter registered.
    func getViewPresenter<P, V>(_ key: AnyHashable) -> P? where P: ViewPresenter<V> {
        if let p = presenterStore.presenters[key] {
            return p as? P
        }
        else {
            if let gen = presenterStore.presenterBuilders[key] {
                let p = gen()
                setViewPresenter(key, p)
                return p as? P
            }
        }
        return nil
    }
    
    /// Remove the presenter with key.
    /// - Parameter key: The key of presenter to remove.
    func removeViewPresenter(_ key: AnyHashable) {
        if let p = presenterStore.presenters[key] {
            remove(child: p)
        }
        presenterStore.presenters[key] = nil
    }
    
    
    /// Add child with type identifier. It's helpful when type is explicit.
    /// ```swift
    /// // register lazy:
    /// typeBoxLazy({ MyViewPresenter() })
    ///
    /// // register immediately
    /// typeBox(MyViewPresenter())
    ///
    /// // get:
    /// if let presenter: MyViewPresenter = typeUnbox() {
    ///     ...
    /// }
    /// ```
    
    
    /// Register presenter with its type by lazy. Presenter will create when first time getting it.
    func typeBoxLazy<P, V>(_ value: @escaping ()->P) where P: ViewPresenter<V> {
        setLazyViewPresenter(ObjectIdentifier(P.self), value)
    }
    
    /// Register presenter with its type.
    @discardableResult
    func typeBox<P, V>(_ value: P) -> P where P: ViewPresenter<V> {
        setViewPresenter(ObjectIdentifier(P.self), value)
        return value
    }
    
    /// Get the presenter registered with return type, and convert to this type if possible.
    /// It will register the presenter when call it first time.
    func typeUnboxLazy<P, V>(_ value: @escaping ()->P) -> P? where P: ViewPresenter<V> {
        if let p: P = typeUnbox() {
            return p
        }
        typeBoxLazy(value)
        return typeUnbox()
    }
    
    /// Get the presenter registered with return type, and convert to this type if possible.
    /// - Returns: Presenter with type `T`
    func typeUnbox<T>() -> T? {
        let p = getViewPresenter(ObjectIdentifier(T.self))
        return p as? T
    }
    
    /// Remove the presenter registered with type `T`.
    func removeTypeBox<T>(_ type: T.Type) {
        removeViewPresenter(ObjectIdentifier(type))
    }
}

/// A presenter stored children by identifier.
@MainActor
open class IdentifierViewGroupPresenter<View>: ViewPresenter<View>, ViewPresenterIdentify {
    
    public var presenterStore = ViewPresenterIdentifierStore()
    
}



