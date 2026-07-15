//
//  ViewPresenterNotifiable.swift
//  DDComponent
//
//  Created by daniel on 2023/5/19.
//

import Foundation

public enum NotifyScope {
    case global             // Notify from root.
    case reusable           // Notify from nearest reusable parent presenter
    case children           // Notify to its chidren
    case childrenAndSelf    // Notify to its children and itself
    case parents            // Notify to its parents, until to root presenter
}

@MainActor
public protocol ViewPresenterNotifiable: AnyObject {
    func notify<T>(listener: T.Type,
                   scope: NotifyScope,
                   from notifier: AnyObject?,
                   _ closure:(T)->Void)
}

extension ViewPresenterNotifiable {
    
    /// Notify the message from root presenter
    public func notifyGlobal<T>(listener: T.Type, from notifier: AnyObject? = nil, _ closure:(T)->Void) {
        notify(listener: listener, scope: .global, from: notifier, closure)
    }
    
    /// Notify the message from nearest reusable parent presenter.
    public func notifyReusable<T>(listener: T.Type, from notifier: AnyObject? = nil, _ closure:(T)->Void) {
        notify(listener: listener, scope: .reusable, from: notifier, closure)
    }
    
    /// Notify the message to children presenters
    public func notifyChildren<T>(listener: T.Type, from notifier: AnyObject? = nil, _ closure:(T)->Void) {
        notify(listener: listener, scope: .children, from: notifier, closure)
    }
    
    public func notifyParents<T>(listener: T.Type, from notifier: AnyObject? = nil, _ closure:(T)->Void) {
        notify(listener: listener, scope: .parents, from: notifier, closure)
    }
    
    /// Notify the message, and the notifier is self.
    public func notify<T>(listener: T.Type, scope: NotifyScope, _ closure:(T)->Void) {
        notify(listener: listener, scope: scope, from: self, closure)
    }
    
    // ===== deprecated ====
    
    /// Notify the message to all presenters
    @available(*, deprecated, message:"Use notifyGlobal() instead")
    public func notify<T>(listener: T.Type, _ closure:(T)->Void) {
        notify(listener: listener, scope: .global, from: nil, closure)
    }
    
    /// Internal usage, prevent notify from self.
    @available(*, deprecated, message:"Use notifyChildren() instead")
    public func notifyChildren<T>(listener: T.Type, from: AnyObject, _ closure:(T)->Void) {
        notify(listener: listener, scope: .children, from: from, closure)
    }
}
