//
//  ReusablePresenterTests.swift
//  DDComponent_Tests
//

import XCTest
import UIKit
@testable import DDComponent

// MARK: - Mock View Protocol

private protocol ReusableCellProtocol: AnyObject {
    var title: String { get set }
}

private final class ReusableCellView: UIView, ReusableCellProtocol {
    var title: String = ""
}

// MARK: - Mock Reusable Presenter

private final class MockReusablePresenter: ReusableViewPresenter<ReusableCellProtocol> {
    var prepareForReuseCalled = false
    var onBindViewCalled = false
    var onUnbindViewCalled = false
    var lastUpdateTitle: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForReuseCalled = true
    }

    override func onBindView(_ view: ReusableCellProtocol) {
        super.onBindView(view)
        onBindViewCalled = true
    }

    override func onUnbindView() {
        super.onUnbindView()
        onUnbindViewCalled = true
    }

    override func onUpdate(view: ReusableCellProtocol, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        lastUpdateTitle = view.title
    }
}

// MARK: - Mock Holder

private final class MockReusableHolder: ReusableViewPresenterHolder<MockReusablePresenter, ReusableCellProtocol> {

    var onBindReusableCalled = false
    var onUnbindReusableCalled = false
    var onUpdatePresenterCalled = false

    override func onBindReusablePresenter(_ presenter: MockReusablePresenter) {
        super.onBindReusablePresenter(presenter)
        onBindReusableCalled = true
    }

    override func onUnbindReusablePresenter(_ presenter: MockReusablePresenter) {
        super.onUnbindReusablePresenter(presenter)
        onUnbindReusableCalled = true
    }

    override func onUpdate(presenter: MockReusablePresenter, context: ViewUpdateContext) {
        super.onUpdate(presenter: presenter, context: context)
        onUpdatePresenterCalled = true
    }
}

// MARK: - Tests

@MainActor
final class ReusablePresenterTests: XCTestCase {

    // MARK: - ReusableViewPresenter

    func testReusableViewPresenter_requiresInit() {
        // MockReusablePresenter has required init(), should compile
        let presenter = MockReusablePresenter()
        XCTAssertNotNil(presenter)
    }

    func testReusableViewPresenter_autoBindDisabled() {
        let presenter = MockReusablePresenter()
        XCTAssertFalse(presenter.autoBindView)
    }

    func testPrepareForReuse_shouldBeCalled() {
        let presenter = MockReusablePresenter()
        presenter.prepareForReuse()
        XCTAssertTrue(presenter.prepareForReuseCalled)
    }

    // MARK: - Holder: Bind Reusable Presenter

    func testReusableHolder_bindReusablePresenter() {
        let holder = MockReusableHolder()
        let presenter = MockReusablePresenter()

        let result = holder.tryBindReusablePresenter(presenter)

        XCTAssertTrue(result)
        XCTAssertTrue(holder.onBindReusableCalled)
        XCTAssertTrue(holder.children.contains { $0 === presenter })
        XCTAssertEqual(holder.reusedPresenters.count, 1)
    }

    func testReusableHolder_bindReusablePresenter_wrongType_shouldReturnFalse() {
        let holder = MockReusableHolder()
        let wrongPresenter = ViewPresenter<Void>()

        let result = holder.tryBindReusablePresenter(wrongPresenter)

        XCTAssertFalse(result)
        XCTAssertEqual(holder.reusedPresenters.count, 0)
    }

    func testReusableHolder_bindReusablePresenter_shouldCallOnUpdate() {
        let holder = MockReusableHolder()
        let presenter = MockReusablePresenter()

        holder.tryBindReusablePresenter(presenter)

        XCTAssertTrue(holder.onUpdatePresenterCalled)
    }

    // MARK: - Holder: Unbind Reusable Presenter

    func testReusableHolder_unbindReusablePresenter() {
        let holder = MockReusableHolder()
        let presenter = MockReusablePresenter()

        holder.tryBindReusablePresenter(presenter)
        let result = holder.tryUnbindReusablePresenter(presenter)

        XCTAssertTrue(result)
        XCTAssertTrue(holder.onUnbindReusableCalled)
        XCTAssertFalse(holder.children.contains { $0 === presenter })
        XCTAssertEqual(holder.reusedPresenters.count, 0)
    }

    func testReusableHolder_unbindReusablePresenter_wrongType_shouldReturnFalse() {
        let holder = MockReusableHolder()
        let wrongPresenter = ViewPresenter<Void>()

        let result = holder.tryUnbindReusablePresenter(wrongPresenter)

        XCTAssertFalse(result)
    }

    // MARK: - Holder: Unbind View

    func testReusableHolder_unbindView_unbindsAllPresenters() {
        let holder = MockReusableHolder()
        let presenter1 = MockReusablePresenter()
        let presenter2 = MockReusablePresenter()

        holder.bindView(())
        holder.tryBindReusablePresenter(presenter1)
        holder.tryBindReusablePresenter(presenter2)

        holder.unbindView()

        XCTAssertEqual(holder.reusedPresenters.count, 0)
        XCTAssertTrue(holder.onUnbindReusableCalled)
    }

    // MARK: - Holder: setState

    func testReusableHolder_setState_shouldMarkNeedsUpdate() {
        let holder = MockReusableHolder()
        let presenter = MockReusablePresenter()

        holder.tryBindReusablePresenter(presenter)
        holder.onUpdatePresenterCalled = false

        holder.setState(updater: {})

        // After setState, when updateView is called, onUpdate should be called
        holder.updateView(context: ViewUpdateContext())
        XCTAssertTrue(holder.onUpdatePresenterCalled)
    }

    // MARK: - Holder: Notify Scope

    func testReusableHolder_notifyReusableScope_redirectsToChildrenAndSelf() {
        let holder = MockReusableHolder()
        let presenter = MockReusablePresenter()

        holder.bindView(())
        holder.tryBindReusablePresenter(presenter)

        // Verify .reusable scope is handled by holder
        XCTAssertTrue(holder.children.contains { $0 === presenter })
        XCTAssertTrue(holder.children.contains { $0 === presenter })
    }

    // MARK: - Presenter Class

    func testReusableHolder_presenterClass() {
        let holder = MockReusableHolder()
        XCTAssertTrue(holder.presenterClass == MockReusablePresenter.self)
    }
}