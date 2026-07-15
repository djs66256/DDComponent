//
//  Service.swift
//  DDComponent
//
//  Created by daniel on 2023/5/25.
//

import Foundation

public protocol Service: AnyObject {}

@MainActor
public protocol ServiceNotifier {
    func notify<T>(listener: T.Type,
                   scope: NotifyScope,
                   from notifier: AnyObject?,
                   _ closure:(T)->Void)
}

@MainActor
public protocol NotifiableService: Service {
    var notifier: ServiceNotifier? { get set }
}

extension NotifiableService {
    
    /// Notify the message from root presenter
    public func notifyGlobal<T>(listener: T.Type, _ closure:(T)->Void) {
        notifier?.notify(listener: listener, scope: .global, from: self, closure)
    }
    
    /// Notify the message from nearest reusable parent presenter.
    public func notifyReusable<T>(listener: T.Type, _ closure:(T)->Void) {
        notifier?.notify(listener: listener, scope: .reusable, from: self, closure)
    }
    
    /// Notify the message to children presenters
    public func notifyChildren<T>(listener: T.Type, _ closure:(T)->Void) {
        notifier?.notify(listener: listener, scope: .children, from: self, closure)
    }
    
    @available(*, deprecated, message:"Use notifyGlobal() instead")
    public func notify<T>(listener: T.Type, _ closure: (T) -> Void) {
        notifyGlobal(listener: listener, closure)
    }
}

@MainActor
public protocol ManagerService: Service {
    var provider: ServiceProvider? { get set }
}

extension ManagerService {
    public func getService<T>(_ type: T.Type) -> T? {
        return provider?.getService(type)
    }
}

@MainActor
public protocol ServiceProvider {
    func getService<T>(_ type: T.Type) -> T?
}

public protocol ServiceRegistrar: ServiceProvider {
    func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T)
    
    func unregister<T>(service: T.Type)
}

extension ServiceRegistrar {
    public func register<T>(service: T.Type, _ builder: @escaping () -> T) {
        register(service: service, lazy: true, builder)
    }
}
