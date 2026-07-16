//
//  PresenterTreeTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Spy Presenter

private final class SpyPresenter: ViewPresenter<Void> {

    var lifecycleCalls: [String] = []

    var onAttachCalled = false
    var onDetachCalled = false
    var onAttachToRootCalled = false
    var onDetachFromRootCalled = false
    var onBindViewCalled = false
    var onUnbindViewCalled = false

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        onAttachCalled = true
        lifecycleCalls.append("onAttach")
    }

    override func onDetach() {
        super.onDetach()
        onDetachCalled = true
        lifecycleCalls.append("onDetach")
    }

    override func onAttachToRoot(rootPresenter: RootViewPresentable) {
        super.onAttachToRoot(rootPresenter: rootPresenter)
        onAttachToRootCalled = true
        lifecycleCalls.append("onAttachToRoot")
    }

    override func onDetachFromRoot() {
        super.onDetachFromRoot()
        onDetachFromRootCalled = true
        lifecycleCalls.append("onDetachFromRoot")
    }

    override func onBindView(_ view: Void) {
        super.onBindView(view)
        onBindViewCalled = true
        lifecycleCalls.append("onBindView")
    }

    override func onUnbindView() {
        super.onUnbindView()
        onUnbindViewCalled = true
        lifecycleCalls.append("onUnbindView")
    }
}

// MARK: - Mock Root Presenter

private final class MockRootPresenter: RootViewPresenter<Void> {

    required init() {
        super.init()
    }

    override func onAttach() {
        super.onAttach()
    }
}

// MARK: - Tests

@MainActor
final class PresenterTreeTests: XCTestCase {

    // MARK: - Add Child

    func testAddChild_shouldSetSuperPresenter() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()

        parent.add(child: child)

        XCTAssertTrue(child.superPresenter === parent)
    }

    func testAddChild_shouldTriggerOnAttach() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()

        parent.add(child: child)

        XCTAssertTrue(child.onAttachCalled)
    }

    func testAddChild_shouldTriggerAttachRootRecursively() {
        let root = MockRootPresenter()
        let child = SpyPresenter()

        root.attachSuperPresenter()
        root.add(child: child)

        XCTAssertTrue(child.onAttachToRootCalled)
        XCTAssertTrue(child.rootPresenter === root)
    }

    func testAddChild_alreadyHasParent_shouldRemoveFromOldParent() {
        let parent1 = ViewPresenter<Void>()
        let parent2 = ViewPresenter<Void>()
        let child = SpyPresenter()

        parent1.add(child: child)
        parent2.add(child: child)

        XCTAssertFalse(parent1.children.contains { $0 === child })
        XCTAssertTrue(parent2.children.contains { $0 === child })
        XCTAssertTrue(child.superPresenter === parent2)
    }

    func testAddChild_alreadyInSameParent_shouldMoveToLast() {
        let parent = ViewPresenter<Void>()
        let child1 = ViewPresenter<Void>()
        let child2 = SpyPresenter()

        parent.add(child: child1)
        parent.add(child: child2)
        // child2 should now be at the end
        parent.add(child: child2)

        XCTAssertTrue(parent.children.last as? SpyPresenter === child2)
    }

    // MARK: - Remove Child

    func testRemoveChild_shouldClearSuperPresenter() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()
        parent.add(child: child)

        parent.remove(child: child)

        XCTAssertNil(child.superPresenter)
    }

    func testRemoveChild_shouldTriggerOnDetach() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()
        parent.add(child: child)

        parent.remove(child: child)

        XCTAssertTrue(child.onDetachCalled)
    }

    func testRemoveChild_shouldTriggerDetachFromRoot() {
        let root = MockRootPresenter()
        let child = SpyPresenter()
        root.attachSuperPresenter()
        root.add(child: child)

        root.remove(child: child)

        XCTAssertTrue(child.onDetachFromRootCalled)
        XCTAssertNil(child.rootPresenter)
    }

    func testRemoveChild_notInParent_shouldDoNothing() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()

        parent.remove(child: child)

        XCTAssertNil(child.superPresenter)
        XCTAssertFalse(child.onDetachCalled)
    }

    // MARK: - Remove From Super

    func testRemoveFromSuper_shouldRemoveFromParent() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()
        parent.add(child: child)

        child.removeFromSuper()

        XCTAssertFalse(parent.children.contains { $0 === child })
        XCTAssertNil(child.superPresenter)
    }

    // MARK: - Remove All Children

    func testRemoveAllChildren_shouldClearAll() {
        let parent = ViewPresenter<Void>()
        let child1 = SpyPresenter()
        let child2 = SpyPresenter()
        parent.add(child: child1)
        parent.add(child: child2)

        parent.removeAllChildrenPresenter()

        XCTAssertTrue(parent.children.isEmpty)
        XCTAssertNil(child1.superPresenter)
        XCTAssertNil(child2.superPresenter)
        XCTAssertTrue(child1.onDetachCalled)
        XCTAssertTrue(child2.onDetachCalled)
    }

    // MARK: - Lifecycle Order

    func testLifecycleOrder_addBindUnbindRemove() {
        let root = MockRootPresenter()
        let child = SpyPresenter()

        root.attachSuperPresenter()
        root.add(child: child)
        child.bindView(())

        child.unbindView()
        root.remove(child: child)

        let expectedOrder = [
            "onAttach",
            "onAttachToRoot",
            "onBindView",
            "onUnbindView",
            "onDetach",
            "onDetachFromRoot"
        ]
        XCTAssertEqual(child.lifecycleCalls, expectedOrder)
    }

    // MARK: - hasAttached

    func testHasAttached_afterAddToParent() {
        let parent = ViewPresenter<Void>()
        let child = ViewPresenter<Void>()

        XCTAssertFalse(child.hasAttached)
        parent.add(child: child)
        XCTAssertTrue(child.hasAttached)
    }

    func testHasAttachedRoot_afterAddToRoot() {
        let root = MockRootPresenter()
        let child = SpyPresenter()

        root.attachSuperPresenter()
        XCTAssertFalse(child.hasAttachedRoot)

        root.add(child: child)
        XCTAssertTrue(child.hasAttachedRoot)
    }

    // MARK: - detachAllPresentersRecursive

    func testDetachAllPresentersRecursive_shouldDetachAllChildren() {
        let root = MockRootPresenter()
        let child1 = SpyPresenter()
        let child2 = SpyPresenter()
        root.attachSuperPresenter()
        root.add(child: child1)
        root.add(child: child2)

        root.detachAllPresentersRecursive()

        XCTAssertTrue(root.children.isEmpty)
        XCTAssertNil(child1.superPresenter)
        XCTAssertNil(child2.superPresenter)
        XCTAssertTrue(child1.onDetachCalled)
        XCTAssertTrue(child2.onDetachCalled)
    }

    // MARK: - detachSuperPresenter auto-unbinds

    func testDetachSuperPresenter_shouldUnbindView() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()
        parent.add(child: child)
        child.bindView(())

        XCTAssertTrue(child.hasBoundView)
        child.detachSuperPresenter()

        XCTAssertFalse(child.hasBoundView)
        XCTAssertTrue(child.onUnbindViewCalled)
    }

    // MARK: - add(child:) auto-bind

    func testAddChild_shouldAutoBindView_whenParentHasBoundView() {
        let parent = ViewPresenter<Void>()
        let child = SpyPresenter()
        child.autoBindView = true
        parent.bindView(())
        parent.add(child: child)

        XCTAssertTrue(child.hasBoundView)
        XCTAssertTrue(child.onBindViewCalled)
    }
}