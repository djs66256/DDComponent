//
//  PageServiceManagerTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Mock Service

private protocol TestServiceProtocol: Service {
    var value: String { get }
}

private final class TestServiceImpl: TestServiceProtocol {
    var value: String = "test"
}

// MARK: - Fallthrough

private final class MockFallthrough: PageServiceManagerFallthroughService {
    var services: [AnyHashable: Any] = [:]

    func getService<T>(_ service: T.Type) -> T? {
        let key = ObjectIdentifier(service)
        return services[key] as? T
    }
}

// MARK: - Tests

@MainActor
final class PageServiceManagerTests: XCTestCase {

    func testRegisterEager_serviceCreatedImmediately() {
        let manager = PageServiceManager(provider: nil, notifier: nil)

        manager.register(service: TestServiceProtocol.self, lazy: false) {
            TestServiceImpl()
        }

        let service = manager.getService(TestServiceProtocol.self)
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.value, "test")
    }

    func testRegisterLazy_serviceCreatedOnFirstGet() {
        let manager = PageServiceManager(provider: nil, notifier: nil)

        manager.register(service: TestServiceProtocol.self, lazy: true) {
            TestServiceImpl()
        }

        let service = manager.getService(TestServiceProtocol.self)
        XCTAssertNotNil(service)
    }

    func testGetService_returnsSameInstance() {
        let manager = PageServiceManager(provider: nil, notifier: nil)

        manager.register(service: TestServiceProtocol.self, lazy: false) {
            TestServiceImpl()
        }

        let service1 = manager.getService(TestServiceProtocol.self)
        let service2 = manager.getService(TestServiceProtocol.self)

        XCTAssertTrue(service1 as AnyObject === service2 as AnyObject)
    }

    func testUnregister_clearsService() {
        let manager = PageServiceManager(provider: nil, notifier: nil)

        manager.register(service: TestServiceProtocol.self, lazy: false) {
            TestServiceImpl()
        }
        manager.unregister(service: TestServiceProtocol.self)

        let service = manager.getService(TestServiceProtocol.self)
        XCTAssertNil(service)
    }

    func testFallthroughService() {
        let ft = MockFallthrough()
        let fallthroughService = TestServiceImpl()
        fallthroughService.value = "fallthrough"
        ft.services[ObjectIdentifier(TestServiceProtocol.self)] = fallthroughService

        let manager = PageServiceManager(provider: nil, notifier: nil)
        manager.fallthroughService = ft

        let service = manager.getService(TestServiceProtocol.self)
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.value, "fallthrough")
    }

    func testLocalService_takesPriorityOverFallthrough() {
        let ft = MockFallthrough()
        let fallthroughService = TestServiceImpl()
        fallthroughService.value = "fallthrough"
        ft.services[ObjectIdentifier(TestServiceProtocol.self)] = fallthroughService

        let manager = PageServiceManager(provider: nil, notifier: nil)
        manager.fallthroughService = ft

        manager.register(service: TestServiceProtocol.self, lazy: false) {
            let s = TestServiceImpl()
            s.value = "local"
            return s
        }

        let service = manager.getService(TestServiceProtocol.self)
        XCTAssertEqual(service?.value, "local")
    }
}