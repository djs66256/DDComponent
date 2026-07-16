import Foundation
import DDComponent

protocol CounterService: AnyObject, Service {
    var count: Int { get }
    func increment() -> Int
}

/// Local service — registered via ServiceInstaller(lazy: false)
final class DefaultCounterService: CounterService {
    private(set) var count: Int = 0

    func increment() -> Int {
        count += 1
        print("[ServiceDI] Counter (local) → \(count)")
        return count
    }
}

/// Global downgrade — used when no local service is registered.
/// Set via RootViewPresenterConfig.serviceDowngrade.
final class GlobalCounterService: CounterService {
    private(set) var count: Int = 100

    func increment() -> Int {
        count += 1
        print("[ServiceDI] Counter (global downgrade) → \(count)")
        return count
    }
}
