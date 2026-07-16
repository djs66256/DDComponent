//
//  ManagedViewPresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/6/2.
//

import Foundation
import UIKit

open class ManagedViewPresenter<View>: ViewPresenter<View>, ServiceRegistrar {
    lazy var serviceManager = PageServiceManager(provider: PageServiceManager.Provider(self),
                                                 notifier: PageServiceManager.Notifier(self))
    
    public func register<T>(service: T.Type, lazy: Bool, _ builder: @escaping () -> T) {
        serviceManager.register(service: service, lazy: lazy, builder)
    }
    
    public func unregister<T>(service: T.Type) {
        serviceManager.unregister(type: service)
    }
    
    open override func getService<T>(_ type: T.Type) -> T? {
        if let service = serviceManager.getService(type) {
            return service
        }
        else {
            return super.getService(type)
        }
    }
}
