//
//  PageNotifyManagerTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Listener Protocol

private protocol NotifyManagerTestListener: AnyObject {
    func onNotify(_ message: String)
}

private final class MockNotifyListener: NotifyManagerTestListener {
    var receivedMessages: [String] = []
    func onNotify(_ message: String) {
        receivedMessages.append(message)
    }
}

// MARK: - Tests

@MainActor
final class PageNotifyManagerTests: XCTestCase {

    func testAddListener_shouldBeNotified() {
        let manager = PageNotifyManager()
        let listener = MockNotifyListener()

        manager.add(listener: NotifyManagerTestListener.self, object: listener)
        manager.notify(listener: NotifyManagerTestListener.self, from: nil) {
            $0.onNotify("hello")
        }

        XCTAssertEqual(listener.receivedMessages, ["hello"])
    }

    func testRemoveListener_shouldNotBeNotified() {
        let manager = PageNotifyManager()
        let listener = MockNotifyListener()

        manager.add(listener: NotifyManagerTestListener.self, object: listener)
        manager.remove(listener: NotifyManagerTestListener.self, object: listener)
        manager.notify(listener: NotifyManagerTestListener.self, from: nil) {
            $0.onNotify("hello")
        }

        XCTAssertTrue(listener.receivedMessages.isEmpty)
    }

    func testRemoveAllListeners_ofObject() {
        let manager = PageNotifyManager()
        let listener = MockNotifyListener()

        manager.add(listener: NotifyManagerTestListener.self, object: listener)
        manager.removeAllListeners(of: listener)
        manager.notify(listener: NotifyManagerTestListener.self, from: nil) {
            $0.onNotify("hello")
        }

        XCTAssertTrue(listener.receivedMessages.isEmpty)
    }

    func testNotify_shouldSkipSender() {
        let manager = PageNotifyManager()
        let listener = MockNotifyListener()

        manager.add(listener: NotifyManagerTestListener.self, object: listener)

        // When the sender is the same as the listener, it should skip
        manager.notify(listener: NotifyManagerTestListener.self, from: listener) {
            $0.onNotify("hello")
        }

        XCTAssertTrue(listener.receivedMessages.isEmpty)
    }

    func testMultipleListeners_allShouldBeNotified() {
        let manager = PageNotifyManager()
        let listener1 = MockNotifyListener()
        let listener2 = MockNotifyListener()

        manager.add(listener: NotifyManagerTestListener.self, object: listener1)
        manager.add(listener: NotifyManagerTestListener.self, object: listener2)
        manager.notify(listener: NotifyManagerTestListener.self, from: nil) {
            $0.onNotify("hello")
        }

        XCTAssertEqual(listener1.receivedMessages, ["hello"])
        XCTAssertEqual(listener2.receivedMessages, ["hello"])
    }

    func testListener_weakReference_shouldNotCrashAfterDealloc() {
        let manager = PageNotifyManager()
        var listener: MockNotifyListener? = MockNotifyListener()

        manager.add(listener: NotifyManagerTestListener.self, object: listener!)
        listener = nil

        // Should not crash when listener is deallocated
        manager.notify(listener: NotifyManagerTestListener.self, from: nil) {
            $0.onNotify("hello")
        }

        // No crash = pass
        XCTAssertTrue(true)
    }
}