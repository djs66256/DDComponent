//
//  ViewBindingTests.swift
//  DDComponent_Tests
//

import XCTest
import UIKit
@testable import DDComponent

// MARK: - Mock View Protocol & Implementation

private protocol MockViewProtocol: AnyObject {
    var title: String { get set }
    var onButtonTapped: (() -> Void)? { get set }
}

private final class MockView: UIView, MockViewProtocol {
    var title: String = ""
    var onButtonTapped: (() -> Void)?
}

private final class AnotherMockView: UIView {
    var title: String = ""
}

// MARK: - Mock Presenter

private final class MockViewPresenter: ViewPresenter<MockViewProtocol> {
    var bindViewCalled = false
    var unbindViewCalled = false

    override func onBindView(_ view: MockViewProtocol) {
        super.onBindView(view)
        bindViewCalled = true
    }

    override func onUnbindView() {
        super.onUnbindView()
        unbindViewCalled = true
    }
}

// MARK: - Tests

@MainActor
final class ViewBindingTests: XCTestCase {

    // MARK: - bindView

    func testBindView_shouldCallOnBindView() {
        let presenter = MockViewPresenter()
        let view = MockView()

        presenter.bindView(view)

        XCTAssertTrue(presenter.bindViewCalled)
        XCTAssertTrue(presenter.hasBoundView)
    }

    func testBindView_shouldRetainView() {
        let presenter = MockViewPresenter()
        let view = MockView()

        presenter.bindView(view)

        XCTAssertNotNil(presenter.view)
        XCTAssertTrue(presenter.view === view)
    }

    func testBindView_whenAlreadyBound_shouldUnbindFirst() {
        let presenter = MockViewPresenter()
        let view1 = MockView()
        let view2 = MockView()

        presenter.bindView(view1)
        presenter.bindView(view2)

        XCTAssertTrue(presenter.unbindViewCalled)
        XCTAssertTrue(presenter.bindViewCalled)
        XCTAssertTrue(presenter.view === view2)
    }

    // MARK: - bindWeakView

    func testBindWeakView_shouldNotRetainView() {
        let presenter = MockViewPresenter()
        var view: MockView? = MockView()

        presenter.bindWeakView(view!)

        XCTAssertNotNil(presenter.view)
        XCTAssertTrue(presenter.hasBoundView)

        view = nil
        // After the original view is deallocated, the weak reference should return nil
        XCTAssertNil(presenter.view)
    }

    func testBindWeakView_shouldCallOnBindView() {
        let presenter = MockViewPresenter()
        let view = MockView()

        presenter.bindWeakView(view)

        XCTAssertTrue(presenter.bindViewCalled)
    }

    // MARK: - tryBindView

    func testTryBindView_wrongType_shouldReturnFalse() {
        let presenter = MockViewPresenter() // expects MockViewProtocol
        let view = AnotherMockView() // does NOT conform to MockViewProtocol

        let result = presenter.tryBindView(view)

        XCTAssertFalse(result)
        XCTAssertFalse(presenter.hasBoundView)
        XCTAssertFalse(presenter.bindViewCalled)
    }

    func testTryBindView_correctType_shouldReturnTrue() {
        let presenter = MockViewPresenter()
        let view = MockView()

        let result = presenter.tryBindView(view)

        XCTAssertTrue(result)
        XCTAssertTrue(presenter.hasBoundView)
        XCTAssertTrue(presenter.bindViewCalled)
    }

    func testTryBindWeakView_wrongType_shouldReturnFalse() {
        let presenter = MockViewPresenter()
        let view = AnotherMockView()

        let result = presenter.tryBindWeakView(view)

        XCTAssertFalse(result)
        XCTAssertFalse(presenter.bindViewCalled)
    }

    func testTryBindWeakView_correctType_shouldReturnTrue() {
        let presenter = MockViewPresenter()
        let view = MockView()

        let result = presenter.tryBindWeakView(view)

        XCTAssertTrue(result)
        XCTAssertTrue(presenter.hasBoundView)
    }

    // MARK: - unbindView

    func testUnbindView_shouldCallOnUnbindView() {
        let presenter = MockViewPresenter()
        let view = MockView()
        presenter.bindView(view)

        presenter.unbindView()

        XCTAssertTrue(presenter.unbindViewCalled)
        XCTAssertFalse(presenter.hasBoundView)
        XCTAssertNil(presenter.view)
    }

    func testUnbindView_shouldRecursivelyUnbindChildren() {
        let parent = ViewPresenter<Void>()
        let child = MockViewPresenter()
        parent.add(child: child)
        parent.bindView(())
        child.bindView(MockView())

        parent.unbindView()

        XCTAssertFalse(child.hasBoundView)
        XCTAssertTrue(child.unbindViewCalled)
    }

    func testUnbindView_whenNotBound_shouldDoNothing() {
        let presenter = MockViewPresenter()

        presenter.unbindView()

        XCTAssertFalse(presenter.unbindViewCalled)
    }

    // MARK: - Auto Bind

    func testAutoBindView_whenVoid_shouldBindVoid() {
        let parent = ViewPresenter<Void>()
        let presenter = ViewPresenter<Void>()
        presenter.autoBindView = true
        parent.add(child: presenter)
        parent.bindView(())

        XCTAssertTrue(presenter.hasBoundView)
    }

    func testAutoBindView_disabled_shouldNotAutoBind() {
        let presenter = MockViewPresenter()
        presenter.autoBindView = false

        presenter.tryAutoBindView()

        XCTAssertFalse(presenter.hasBoundView)
    }

    func testAutoBindChildrenPresenterViews_disabled_shouldNotAutoBindChildren() {
        let parent = ViewPresenter<Void>()
        let child = MockViewPresenter()
        parent.add(child: child)
        parent.bindView(())
        parent.autoBindChildrenPresenterViews = false

        // Re-bind to trigger auto-bind of children
        parent.unbindView()
        parent.bindView(())

        XCTAssertFalse(child.hasBoundView)
    }

    // MARK: - anyView

    func testAnyView_shouldReturnView() {
        let presenter = MockViewPresenter()
        let view = MockView()
        presenter.bindView(view)

        XCTAssertTrue(presenter.anyView as? MockView === view)
    }

    func testAnyView_whenNotBound_shouldReturnNil() {
        let presenter = MockViewPresenter()

        XCTAssertNil(presenter.anyView)
    }
}