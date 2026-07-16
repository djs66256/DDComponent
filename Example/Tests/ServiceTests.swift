//
//  ServiceTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Mock Service Protocols

protocol DataService: Service {
    func fetchData() -> String
}

protocol AuthService: Service {
    var isLoggedIn: Bool { get }
}

final class MockDataService: DataService {
    func fetchData() -> String { "mock data" }
}

final class MockAuthService: AuthService {
    var isLoggedIn: Bool = true
}

// MARK: - Notifiable Mock Service

protocol NotifiableMockService: NotifiableService {
    var notifier: ServiceNotifier? { get set }
    func sendNotification()
}

final class NotifiableMockServiceImpl: NotifiableMockService {
    var notifier: ServiceNotifier?
    func sendNotification() {
        // Use notifier to send
    }
}

// MARK: - Manager Mock Service

protocol ManagerMockService: ManagerService {
    var provider: ServiceProvider? { get set }
    func getDataService() -> DataService?
}

final class ManagerMockServiceImpl: ManagerMockService {
    var provider: ServiceProvider?
    func getDataService() -> DataService? {
        return getService(DataService.self)
    }
}

// MARK: - Root Presenter

final class ServiceRootPresenter: RootViewPresenter<Void> {

    required init() {
        super.init()
    }

    override func onAttach() {
        super.onAttach()
    }
}

// MARK: - Tests

@MainActor
final class ServiceTests: XCTestCase {

    // MARK: - Register & Get (Eager)

    func testRegisterAndGetService_eager_shouldReturnImmediately() {
        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        root.register(service: DataService.self, lazy: false) {
            MockDataService()
        }

        let service = root.getService(DataService.self)
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.fetchData(), "mock data")
    }

    // MARK: - Register & Get (Lazy)

    func testRegisterAndGetService_lazy_shouldCreateOnFirstGet() {
        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        root.register(service: DataService.self, lazy: true) {
            MockDataService()
        }

        // First get creates the service
        let service = root.getService(DataService.self)
        XCTAssertNotNil(service)
    }

    func testRegisterAndGetService_lazy_returnsSameInstance() {
        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        root.register(service: DataService.self, lazy: true) {
            MockDataService()
        }

        let service1 = root.getService(DataService.self)
        let service2 = root.getService(DataService.self)

        XCTAssertTrue(service1 as AnyObject === service2 as AnyObject)
    }

    // MARK: - Lookup Chain

    func testServiceLookupChain_childToParent() {
        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        root.register(service: DataService.self, lazy: false) {
            MockDataService()
        }

        let child = ViewPresenter<Void>()
        root.add(child: child)

        let service = child.getService(DataService.self)
        XCTAssertNotNil(service)
    }

    func testServiceLookupChain_rootDowngrade() {
        // Verify that the RootViewPresenterConfig.serviceDowngrade mechanism
        // is functional. The downgrade is consulted when no local service is registered.

        let oldDowngrade = RootViewPresenterConfig.serviceDowngrade

        var downgradeCalled = false
        final class GlobalDowngrade: RootViewPresenterServiceDowngrade {
            let tracker: () -> Void
            init(tracker: @escaping () -> Void) { self.tracker = tracker }
            func getService<T>(_ type: T.Type) -> T? {
                tracker()
                return nil
            }
        }
        RootViewPresenterConfig.serviceDowngrade = GlobalDowngrade(tracker: { downgradeCalled = true })

        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        // This should trigger the downgrade
        let _ = root.getService(DataService.self)

        XCTAssertTrue(downgradeCalled, "Global downgrade should be consulted")

        RootViewPresenterConfig.serviceDowngrade = oldDowngrade
    }

    // MARK: - Unregister

    func testUnregisterService_shouldReturnNil() {
        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        root.register(service: DataService.self, lazy: false) {
            MockDataService()
        }

        root.unregister(service: DataService.self)

        let service = root.getService(DataService.self)
        XCTAssertNil(service)
    }

    // MARK: - NotifiableService

    func testNotifiableService_shouldSetNotifier() {
        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        root.register(service: NotifiableMockService.self, lazy: false) {
            NotifiableMockServiceImpl()
        }

        let service = root.getService(NotifiableMockService.self)
        XCTAssertNotNil(service)
        // Notifier should be set automatically
        XCTAssertNotNil(service?.notifier)
    }

    // MARK: - ManagerService

    func testManagerService_shouldSetProvider() {
        let root = ServiceRootPresenter()
        root.attachSuperPresenter()

        root.register(service: DataService.self, lazy: false) {
            MockDataService()
        }
        root.register(service: ManagerMockService.self, lazy: false) {
            ManagerMockServiceImpl()
        }

        let manager = root.getService(ManagerMockService.self)
        XCTAssertNotNil(manager)
        // Provider should be set automatically
        XCTAssertNotNil(manager?.provider)

        // Manager should be able to look up other services
        let dataService = manager?.getDataService()
        XCTAssertNotNil(dataService)
    }

    // MARK: - ManagedViewPresenter

    func testManagedViewPresenter_registerAndGetService() {
        let presenter = ManagedViewPresenter<Void>()

        presenter.register(service: DataService.self, lazy: false) {
            MockDataService()
        }

        let service = presenter.getService(DataService.self)
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.fetchData(), "mock data")
    }
}