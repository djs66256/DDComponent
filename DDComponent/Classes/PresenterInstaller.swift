//
//  PresenterInstaller.swift
//  DDComponent
//
//  Created by daniel on 2022/9/16.
//

import Foundation
import UIKit
import SwiftUI

public typealias ViewPresenterInstallable = ViewPresentable & ViewPresenterIdentify & ServiceRegistrar & NotifyRegistrar

@MainActor
public protocol PageInstaller {
    func install(presenter: ViewPresenterInstallable)
}

@MainActor
public struct PresenterInstaller<P, V>: PageInstaller where P: ViewPresenter<V> {
    
    public let lazyLoad: Bool
    public let key: AnyHashable?
    public let builder: ()->P
    
    public init(lazyLoad: Bool = false, key: AnyHashable? = nil, _ builder: @escaping ()->P) {
        self.lazyLoad = lazyLoad
        self.key = key
        self.builder = builder
    }
    
    public func install(presenter: ViewPresenterInstallable) {
        if lazyLoad {
            if let key = key {
                presenter.setLazyViewPresenter(key, builder)
            }
            else {
                presenter.typeBoxLazy(builder)
            }
        }
        else {
            if let key = key {
                presenter.setViewPresenter(key, builder())
            }
            else {
                presenter.typeBox(builder())
            }
        }
    }
}

@inline(__always)
@MainActor
private func _listenTo<P>(_ type: P.Type) -> ServiceInstaller.NotifyInstaller {
    return { p, s in
        assert(s is P)
        p.add(listener: type, object: s)
    }
}

@MainActor
public struct ServiceInstaller<T>: PageInstaller {
    public let type: T.Type
    public let lazy: Bool
    public let builder: ()->T
    fileprivate typealias NotifyInstaller = (ViewPresenterInstallable, AnyObject)->Void
    private let notifiers: [NotifyInstaller]
    
    public init(_ type: T.Type, lazy: Bool = true, _ builder: @escaping ()->T) {
        self.init(type, lazy: lazy, notifiers: [], builder)
    }
    
    private init(_ type: T.Type, lazy: Bool = true, notifiers: [NotifyInstaller], _ builder: @escaping ()->T) {
        self.lazy = lazy
        self.type = type
        self.builder = builder
        self.notifiers = notifiers
    }
    
    public init<P>(_ type: T.Type,
                   lazy: Bool = true,
                   listenTo listener: P.Type,
                   _ builder: @escaping ()->T){
        let notifiers = [_listenTo(listener)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q>(_ type: T.Type,
                      lazy: Bool = true,
                      listenTo listeners: (P.Type, Q.Type),
                      _ builder: @escaping ()->T) {
        let (p, q) = listeners
        let notifiers = [_listenTo(p), _listenTo(q)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R>(_ type: T.Type,
                      lazy: Bool = true,
                         listenTo listeners: (P.Type, Q.Type, R.Type),
                      _ builder: @escaping ()->T) {
        let (p, q, r) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R, S>(_ type: T.Type,
                            lazy: Bool = true,
                            listenTo listeners: (P.Type, Q.Type, R.Type, S.Type),
                            _ builder: @escaping ()->T) {
        let (p, q, r, s) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r), _listenTo(s)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R, S, U>(_ type: T.Type,
                               lazy: Bool = true,
                               listenTo listeners: (P.Type, Q.Type, R.Type, S.Type, U.Type),
                               _ builder: @escaping ()->T) {
        let (p, q, r, s, u) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r), _listenTo(s), _listenTo(u)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R, S, U, V>(_ type: T.Type,
                                  lazy: Bool = true,
                                  listenTo listeners: (P.Type, Q.Type, R.Type, S.Type, U.Type, V.Type),
                                  _ builder: @escaping ()->T) {
        let (p, q, r, s, u, v) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r), _listenTo(s), _listenTo(u), _listenTo(v)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R, S, U, V, W>(_ type: T.Type,
                                     lazy: Bool = true,
                                     listenTo listeners: (P.Type, Q.Type, R.Type, S.Type, U.Type, V.Type, W.Type),
                                     _ builder: @escaping ()->T) {
        let (p, q, r, s, u, v, w) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r), _listenTo(s), _listenTo(u), _listenTo(v), _listenTo(w)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R, S, U, V, W, X>(_ type: T.Type,
                                        lazy: Bool = true,
                                        listenTo listeners: (P.Type, Q.Type, R.Type, S.Type, U.Type, V.Type, W.Type, X.Type),
                                        _ builder: @escaping ()->T) {
        let (p, q, r, s, u, v, w, x) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r), _listenTo(s), _listenTo(u), _listenTo(v), _listenTo(w), _listenTo(x)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R, S, U, V, W, X, Y>(_ type: T.Type,
                                           lazy: Bool = true,
                                           listenTo listeners: (P.Type, Q.Type, R.Type, S.Type, U.Type, V.Type, W.Type, X.Type, Y.Type),
                                           _ builder: @escaping ()->T) {
        let (p, q, r, s, u, v, w, x, y) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r), _listenTo(s), _listenTo(u), _listenTo(v), _listenTo(w), _listenTo(x), _listenTo(y)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public init<P, Q, R, S, U, V, W, X, Y, Z>(_ type: T.Type,
                                              lazy: Bool = true,
                                              listenTo listeners: (P.Type, Q.Type, R.Type, S.Type, U.Type, V.Type, W.Type, X.Type, Y.Type, Z.Type),
                                              _ builder: @escaping ()->T) {
        let (p, q, r, s, u, v, w, x, y, z) = listeners
        let notifiers = [_listenTo(p), _listenTo(q), _listenTo(r), _listenTo(s), _listenTo(u), _listenTo(v), _listenTo(w), _listenTo(x), _listenTo(y), _listenTo(z)]
        self.init(type, lazy: lazy, notifiers: notifiers, builder)
    }
    
    public func install(presenter: ViewPresenterInstallable) {
        presenter.register(service: type, lazy: lazy, builder)
        
        if !notifiers.isEmpty, let service = presenter.getService(type) as? AnyObject {
            for notifier in notifiers {
                notifier(presenter, service)
            }
        }
    }
}

struct GroupInstaller: PageInstaller {
    var installers: [PageInstaller]
    init(installers: [PageInstaller]) {
        self.installers = installers
    }
    
    public func install(presenter: ViewPresenterInstallable) {
        for installer in installers {
            installer.install(presenter: presenter)
        }
    }
}

struct NopInstaller: PageInstaller {
    public func install(presenter: ViewPresenterInstallable) {
        
    }
}

@MainActor
@resultBuilder
public struct PageInstallerBuilder {
    public typealias Component = PageInstaller
    public static func buildBlock(_ components: Component...) -> Component {
        GroupInstaller(installers: components)
    }
    
    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        GroupInstaller(installers: components)
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? NopInstaller()
    }
}

extension ViewPresentable where Self: ViewPresenterIdentify & ServiceRegistrar & NotifyRegistrar {
    
    /// All convenient method to register presenters, services.
    /// - Parameter builder: Register builder by ResultBuilder
    public func install(@PageInstallerBuilder builder:  ()->PageInstaller) {
        let installer = builder()
        installer.install(presenter: self)
    }
}
