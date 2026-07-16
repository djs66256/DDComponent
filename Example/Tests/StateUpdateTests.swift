//
//  StateUpdateTests.swift
//  DDComponent_Tests
//

import XCTest
import UIKit
@testable import DDComponent

// MARK: - Mock View Protocol

private protocol StateUpdateViewProtocol: AnyObject {
    var title: String { get set }
    var count: Int { get set }
    var needsLayoutCalled: Bool { get set }
}

private final class StateUpdateView: UIView, StateUpdateViewProtocol {
    var title: String = ""
    var count: Int = 0
    var needsLayoutCalled: Bool = false

    override func setNeedsLayout() {
        super.setNeedsLayout()
        needsLayoutCalled = true
    }
}

// MARK: - Mock Root Presenter

private final class StateUpdateRootPresenter: RootViewPresenter<StateUpdateViewProtocol> {

    var stateTitle: String = ""
    var stateCount: Int = 0

    var onUpdateCallCount = 0
    var lastContext: ViewUpdateContext?

    required init() {
        super.init()
    }

    override func onAttach() {
        super.onAttach()
    }

    override func onUpdate(view: StateUpdateViewProtocol, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        view.title = stateTitle
        view.count = stateCount
        onUpdateCallCount += 1
        lastContext = context
    }
}

// MARK: - Tests

@MainActor
final class StateUpdateTests: XCTestCase {

    // MARK: - setState triggers onUpdate

    func testSetState_shouldTriggerOnUpdate() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        root.setState {
            // state change
        }

        root.updateViewIfNeeded()

        XCTAssertGreaterThan(root.onUpdateCallCount, 0)
    }

    func testSetState_updateViewImmediately() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        let beforeCount = root.onUpdateCallCount
        root.setState(updater: {}) {
            $0.updateViewImmediately = true
        }

        XCTAssertGreaterThan(root.onUpdateCallCount, beforeCount)
    }

    func testSetState_updatesViewData() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        root.stateTitle = "Hello"
        root.stateCount = 42
        root.setState(updater: {})
        root.updateViewIfNeeded()

        XCTAssertEqual(view.title, "Hello")
        XCTAssertEqual(view.count, 42)
    }

    // MARK: - invalidateLayout

    func testSetState_invalidateLayout() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        root.setState(updater: {}) {
            $0.invalidateLayout = true
        }
        root.updateViewIfNeeded()

        XCTAssertTrue(view.needsLayoutCalled)
    }

    // MARK: - Completion

    func testSetState_completionCallback() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        let expectation = self.expectation(description: "completion called")
        root.setState(updater: {}, context: {
            $0.updateViewImmediately = true
        }, completion: {
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Context Merge

    func testSetState_contextMerge() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        root.setState(updater: {}) {
            $0.invalidateLayout = true
        }

        root.setState(updater: {}) {
            $0.animated = true
        }

        root.updateViewIfNeeded()

        let context = root.lastContext
        XCTAssertNotNil(context)
    }

    // MARK: - Without Pipeline

    func testSetState_withoutPipeline_shouldNotCrash() {
        let presenter = ViewPresenter<Void>()

        // No pipeline, no root — should not crash
        presenter.setState {
            // just testing it doesn't crash
        }

        XCTAssertTrue(true)
    }

    // MARK: - Bind triggers onUpdate

    func testBindView_triggersOnUpdate() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()

        let beforeCount = root.onUpdateCallCount
        root.bindView(view)
        root.updateViewIfNeeded()

        XCTAssertGreaterThan(root.onUpdateCallCount, beforeCount)
    }

    // MARK: - performBatchUpdate

    func testPerformBatchUpdate_contextPropagation() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        performBatchUpdate({
            root.setState(updater: {})
        }) {
            $0.invalidateLayout = true
        }

        root.updateViewIfNeeded()

        XCTAssertTrue(view.needsLayoutCalled)
    }

    // MARK: - StateChecker Property Wrapper

    func testStateChecker_insideSetState_shouldModify() {
        let root = StateUpdateRootPresenter()
        let view = StateUpdateView()
        root.attachSuperPresenter()
        root.bindView(view)

        var checkedValue = 0
        root.setState {
            checkedValue = 1
        }

        root.updateViewIfNeeded()
        XCTAssertEqual(checkedValue, 1)
    }
}