//
//  NotifyTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Listener Protocol

private protocol TestListener: AnyObject {
    func onEvent(_ message: String)
}

// MARK: - Listener Implementation

private final class MockListener: TestListener {
    var receivedMessages: [String] = []
    var notifyCount: Int = 0

    func onEvent(_ message: String) {
        receivedMessages.append(message)
        notifyCount += 1
    }
}

// MARK: - Sender Presenter

private final class SenderPresenter: ViewPresenter<Void> {

    func sendChildren(_ message: String) {
        notifyChildren(listener: TestListener.self) {
            $0.onEvent(message)
        }
    }

    func sendChildrenAndSelf(_ message: String) {
        notify(listener: TestListener.self, scope: .childrenAndSelf) {
            $0.onEvent(message)
        }
    }

    func sendParents(_ message: String) {
        notifyParents(listener: TestListener.self) {
            $0.onEvent(message)
        }
    }

    func sendGlobal(_ message: String) {
        notifyGlobal(listener: TestListener.self) {
            $0.onEvent(message)
        }
    }
}

// MARK: - Listener Presenter (implements TestListener)

private final class ListenerPresenter: ViewPresenter<Void>, TestListener {
    var receivedMessages: [String] = []
    var notifyCount: Int = 0

    func onEvent(_ message: String) {
        receivedMessages.append(message)
        notifyCount += 1
    }
}

// MARK: - Root Presenter

private final class NotifyRootPresenter: RootViewPresenter<Void>, TestListener {

    var receivedMessages: [String] = []
    var notifyCount: Int = 0

    required init() {
        super.init()
    }

    override func onAttach() {
        super.onAttach()
    }

    func onEvent(_ message: String) {
        receivedMessages.append(message)
        notifyCount += 1
    }
}

// MARK: - Tests

@MainActor
final class NotifyTests: XCTestCase {

    // MARK: - Children Scope

    func testNotifyChildren_shouldReachAllDescendants() {
        let root = NotifyRootPresenter()
        let parent = SenderPresenter()
        let child1 = ListenerPresenter()
        let child2 = ListenerPresenter()
        let grandchild = ListenerPresenter()

        root.attachSuperPresenter()
        root.add(child: parent)
        parent.add(child: child1)
        parent.add(child: child2)
        child1.add(child: grandchild)

        parent.sendChildren("hello")

        XCTAssertEqual(child1.notifyCount, 1)
        XCTAssertEqual(child1.receivedMessages, ["hello"])
        XCTAssertEqual(child2.notifyCount, 1)
        XCTAssertEqual(grandchild.notifyCount, 1)
    }

    func testNotifyChildren_shouldNotReachParent() {
        let root = NotifyRootPresenter()
        let child = SenderPresenter()

        root.attachSuperPresenter()
        root.add(child: child)

        root.notifyCount = 0
        child.sendChildren("hello")

        // Root should NOT receive children-scoped messages
        XCTAssertEqual(root.notifyCount, 0)
    }

    func testNotifyChildrenAndSelf_shouldIncludeSelf() {
        let root = NotifyRootPresenter()
        let parent = ListenerPresenter() // implements TestListener
        let sender = SenderPresenter()
        let child = ListenerPresenter()

        root.attachSuperPresenter()
        root.add(child: parent)
        parent.add(child: sender)
        sender.add(child: child)

        parent.notifyCount = 0
        // sender sends childrenAndSelf — parent is above sender, child is below
        // parent should NOT receive (it's above), child should receive
        sender.sendChildrenAndSelf("hello")

        // parent is not in scope (above sender)
        XCTAssertEqual(parent.notifyCount, 0)
        // child should receive
        XCTAssertEqual(child.notifyCount, 1)
        XCTAssertEqual(child.receivedMessages, ["hello"])
    }

    // MARK: - Parents Scope

    func testNotifyParents_shouldReachAllAncestors() {
        let root = NotifyRootPresenter()
        let parent = ListenerPresenter()
        let child = SenderPresenter()

        root.attachSuperPresenter()
        root.add(child: parent)
        parent.add(child: child)

        child.sendParents("hello")

        XCTAssertEqual(parent.notifyCount, 1)
        XCTAssertEqual(root.notifyCount, 1)
    }

    func testNotifyParents_shouldNotReachSiblings() {
        let root = NotifyRootPresenter()
        let parent = ListenerPresenter()
        let child1 = SenderPresenter()
        let child2 = ListenerPresenter()

        root.attachSuperPresenter()
        root.add(child: parent)
        parent.add(child: child1)
        parent.add(child: child2)

        child2.notifyCount = 0
        child1.sendParents("hello")

        // Sibling should NOT receive parents-scoped messages
        XCTAssertEqual(child2.notifyCount, 0)
    }

    // MARK: - Global Scope

    func testNotifyGlobal_shouldReachRootThenBroadcast() {
        let root = NotifyRootPresenter()
        let child = SenderPresenter()

        root.attachSuperPresenter()
        root.add(child: child)

        child.sendGlobal("hello")

        // Root should receive global messages
        XCTAssertEqual(root.notifyCount, 1)
        XCTAssertEqual(root.receivedMessages, ["hello"])
    }

    // MARK: - Sender Exclusion

    func testNotify_shouldNotNotifySender() {
        let root = NotifyRootPresenter()
        let sender = ListenerPresenter()
        let child = ListenerPresenter()

        root.attachSuperPresenter()
        root.add(child: sender)
        sender.add(child: child)

        sender.notifyCount = 0
        // Send via childrenAndSelf scope — sender should be excluded
        sender.notify(listener: TestListener.self, scope: .childrenAndSelf) {
            $0.onEvent("hello")
        }

        // Sender itself should NOT be notified
        XCTAssertEqual(sender.notifyCount, 0)
        // But children should be notified
        XCTAssertEqual(child.notifyCount, 1)
    }

    // MARK: - After Detach

    func testNotify_afterDetach_shouldNotReceive() {
        let root = NotifyRootPresenter()
        let parent = ListenerPresenter()
        let child = SenderPresenter()

        root.attachSuperPresenter()
        root.add(child: parent)
        parent.add(child: child)

        // Detach the child
        parent.remove(child: child)

        parent.notifyCount = 0
        child.sendParents("hello")

        // Parent should NOT receive because child is detached
        XCTAssertEqual(parent.notifyCount, 0)
    }

    // MARK: - Multiple Listeners

    func testNotify_multipleListenersSameType() {
        let root = NotifyRootPresenter()
        let parent = SenderPresenter()
        let child1 = ListenerPresenter()
        let child2 = ListenerPresenter()

        root.attachSuperPresenter()
        root.add(child: parent)
        parent.add(child: child1)
        parent.add(child: child2)

        parent.sendChildren("hello")

        XCTAssertEqual(child1.notifyCount, 1)
        XCTAssertEqual(child2.notifyCount, 1)
    }

    // MARK: - Convenience Methods

    func testNotifyGlobal_convenienceMethod() {
        let root = NotifyRootPresenter()
        let child = ViewPresenter<Void>()

        root.attachSuperPresenter()
        root.add(child: child)

        root.notifyCount = 0
        child.notifyGlobal(listener: TestListener.self) {
            $0.onEvent("global")
        }

        XCTAssertEqual(root.notifyCount, 1)
    }
}