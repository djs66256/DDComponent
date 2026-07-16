//
//  PageNotifyManager.swift
//  DDComponent
//
//  Created by daniel on 2022/8/31.
//

import Foundation
import UIKit

@MainActor
public protocol NotifyRegistrar {
    func add<T>(listener: T.Type, object: AnyObject)
    func remove<T>(listener: T.Type, object: AnyObject)
}

@MainActor
public final class PageNotifyManager: NotifyRegistrar {
    struct ListenerObject: Hashable {
        var key: ObjectIdentifier
        weak var value: AnyObject?
        init<T: AnyObject>(_ value: T) {
            self.value = value
            self.key = ObjectIdentifier(value)
        }
        func unbox<T>() -> T? {
            return value as? T
        }
        
        static func == (lhs: PageNotifyManager.ListenerObject, rhs: PageNotifyManager.ListenerObject) -> Bool {
            lhs.key == rhs.key
        }
        
        var hashValue: Int {
            key.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            key.hash(into: &hasher)
        }
    }
    
    var listeners: [ObjectIdentifier: Set<ListenerObject>] = [:]
    
    public func add<T>(listener: T.Type, object: AnyObject) {
        assert(object is T, "Object MUST implement type \(T.self)")
        if var container = listeners[ObjectIdentifier(listener)] {
            container.insert(ListenerObject(object))
            listeners[ObjectIdentifier(listener)] = container
        }
        else {
            var set = Set<ListenerObject>()
            set.insert(ListenerObject(object))
            listeners[ObjectIdentifier(listener)] = set
        }
    }
    
    public func remove<T>(listener: T.Type, object: AnyObject) {
        assert(object is T, "Object MUST implement type \(T.self)")
        listeners[ObjectIdentifier(listener)]?.remove(ListenerObject(object))
    }
    
    public func removeAllListeners(of object: AnyObject) {
        for (key, var v) in listeners {
            v.remove(ListenerObject(object))
            listeners[key] = v
        }
    }
    
    private class DummyNotifier {}
    private static let dummyNotifier = ObjectIdentifier(DummyNotifier.self)
    public func notify<T>(listener: T.Type, from notifier: AnyObject?, _ closure:(T)->Void) {
        let from = {
            if let notifier = notifier {
                return ObjectIdentifier(notifier)
            }
            else {
                return PageNotifyManager.dummyNotifier
            }
        }()
        if let notifiees = listeners[ObjectIdentifier(listener)] {
            for notifiee in notifiees {
                if let realObject = notifiee.value as? T, notifiee.key != from {
                    closure(realObject)
                }
            }
        }
    }
}
