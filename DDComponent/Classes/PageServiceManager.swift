//
//  PageServiceManager.swift
//  DDComponent
//
//  Created by daniel on 2022/8/31.
//

import Foundation

public protocol PageServiceManagerFallthroughService {
    func getService<T>(_ service: T.Type) -> T?
}

public final class PageServiceManager: ServiceRegistrar {
    
    var notifier: ServiceNotifier?
    var provider: ServiceProvider?
    public var fallthroughService: PageServiceManagerFallthroughService? = nil
    
    public init<T>(presenter: T) where T: ViewPresentable {
        self.notifier = Notifier(presenter)
    }
    public init(provider: ServiceProvider?, notifier: ServiceNotifier?) {
        self.provider = provider
        self.notifier = notifier
    }
    
    @MainActor(unsafe) public func getService<T>(_ service: T.Type) -> T? {
        if let s = get(type: service) {
            return s
        }
        else {
            if let fallthroughService {
                return fallthroughService.getService(service)
            }
            return nil
        }
    }
    
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T) {
        register(type: service, lazy: lazy, generator: builder)
    }
    
    public func unregister<T>(service: T.Type) {
        unregister(type: service)
    }
    
    struct Key : Hashable {
        let type: Any.Type
        
        static func == (lhs: Key, rhs: Key) -> Bool {
            lhs.type == rhs.type
        }
        
        public func hash(into hasher: inout Hasher) {
            ObjectIdentifier(type).hash(into: &hasher)
        }
    }
    
    struct Value {
        let service: Any?
        
        init(service: Any?) {
            self.service = service
        }
    }
    
    struct Generator {
        let generator: () -> Any?
        
        func generate() -> Any? {
            generator()
        }
    }
    
    private let lock = NSRecursiveLock()
    private var services = [Key: Value]()
    private var serviceMetas = [Key: Generator]()
    
    func get<T>(type: T.Type) -> T? {
        defer {
            lock.unlock()
        }
        lock.lock()
        
        let key = Key(type: type)
        if let value = services[key] {
            return value.service as? T
        }
        else {
            let service = generateNoLock(type: type)
            services[key] = Value(service: service)
            return service
        }
    }
    
    func register<T>(type: T.Type, lazy: Bool, generator: @escaping ()->T?) {
        defer {
            lock.unlock()
        }
        lock.lock()
        let key = Key(type: type)
        let gen = Generator(generator: generator)
        serviceMetas[key] = gen
        
        if !lazy {
            let service = generateNoLock(type: type)
            services[key] = Value(service: service)
        }
    }
    
    func unregister<T>(type: T.Type) {
        defer {
            lock.unlock()
        }
        lock.lock()
        let key = Key(type: type)
        serviceMetas[key] = nil
        services[key] = nil
    }
    
    private func generateNoLock<T>(type: T.Type) -> T? {
        if let gen = serviceMetas[Key(type: type)] {
            if let value = gen.generate() {
                assert(value is T, "Service \(value) is not implement \(T.self)")
                if let value = value as? NotifiableService {
                    value.notifier = notifier
                }
                if let value = value as? ManagerService {
                    value.provider = provider ?? Provider(self)
                }
                return value as? T
            }
        }
        return nil
    }
    
    internal struct Provider<T>: ServiceProvider where T: ServiceProvider & AnyObject {
        weak var provider: T?
        init(_ provider: T? = nil) {
            self.provider = provider
        }
        func getService<S>(_ type: S.Type) -> S? {
            return provider?.getService(type)
        }
    }
    
    internal struct Notifier<T>: ServiceNotifier where T: ViewPresenterNotifiable {
        weak var notifier: T?
        init(_ notifier: T? = nil) {
            self.notifier = notifier
        }
        
        func notify<N>(listener: N.Type, scope: NotifyScope, from notifier: AnyObject?, _ closure: (N) -> Void) {
            self.notifier?.notify(listener: listener, scope: scope, from: notifier, closure)
        }
    }
}

