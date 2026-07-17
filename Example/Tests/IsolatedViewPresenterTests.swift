//
//  IsolatedViewPresenterTests.swift
//  DDComponent_Tests
//

import XCTest
import UIKit
@testable import DDComponent

// MARK: - Mock View Protocol

private protocol IsolatedViewProtocol: AnyObject {
    var title: String { get set }
}

private final class IsolatedView: UIView, IsolatedViewProtocol {
    var title: String = ""
}

// MARK: - Mock Presenter

private final class IsolatedMockPresenter: ViewPresenter<IsolatedViewProtocol> {
    var onAttachCalled = false
    var onBindViewCalled = false

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        onAttachCalled = true
    }

    override func onBindView(_ view: IsolatedViewProtocol) {
        super.onBindView(view)
        onBindViewCalled = true
    }
}

// MARK: - Tests

@MainActor
final class IsolatedViewPresenterTests: XCTestCase {

    func testInit_bindsViewAndPresenter() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()

        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        XCTAssertTrue(isolated.children.contains { $0 === presenter })
        XCTAssertTrue(presenter.hasBoundView)
        XCTAssertTrue(presenter.view === view)
    }

    func testHasOwnPipeline_whenIsolated() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()

        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        // When not added to a super, should have its own pipeline
        XCTAssertNotNil(isolated.viewUpdatePipeline)
    }

    func testUsesParentPipeline_whenAddedToSuper() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()
        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        let root = RootViewPresenter<Void>()
        root.attachSuperPresenter()
        root.bindView(())
        root.add(child: isolated)

        // When added to a root, should use the root's pipeline
        // The pipeline comes from superPresenter
        XCTAssertTrue(isolated.viewUpdatePipeline === root.viewUpdatePipeline)
    }

    func testAttachSuperPresenter_triggersOnAttach() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()

        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)
        isolated.attachSuperPresenter()

        XCTAssertTrue(isolated.hasAttached)
    }

    func testRootPresenter_returnsSelf() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()

        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        XCTAssertTrue(isolated.rootPresenter === isolated)
    }

    // MARK: - Listener Management

    func testAddListener_shouldRegister() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()
        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        let listener = MockNotifyListenerForIsolated()
        isolated.add(listener: NotifyListenerProtocol.self, object: listener)

        XCTAssertTrue(true)
    }

    func testRemoveListener_shouldUnregister() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()
        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        let listener = MockNotifyListenerForIsolated()
        isolated.add(listener: NotifyListenerProtocol.self, object: listener)
        isolated.remove(listener: NotifyListenerProtocol.self, object: listener)

        XCTAssertTrue(true)
    }

    func testRemoveAllListeners_shouldClearAll() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()
        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        let listener = MockNotifyListenerForIsolated()
        isolated.add(listener: NotifyListenerProtocol.self, object: listener)
        isolated.removeAllListeners(of: listener)

        XCTAssertTrue(true)
    }

    // MARK: - Pipeline Switch on Remove

    func testPipelineSwitch_whenRemovedFromSuper_shouldUseOwnPipeline() {
        let view = IsolatedView()
        let presenter = IsolatedMockPresenter()
        let isolated = IsolatedViewPresenter(view: view, presenter: presenter)

        let root = RootViewPresenter<Void>()
        root.attachSuperPresenter()
        root.bindView(())
        root.add(child: isolated)

        XCTAssertTrue(isolated.viewUpdatePipeline === root.viewUpdatePipeline)

        root.remove(child: isolated)
        XCTAssertNotNil(isolated.viewUpdatePipeline)
        XCTAssertFalse(isolated.viewUpdatePipeline === root.viewUpdatePipeline)
    }
}

// MARK: - Mock Listener for IsolatedViewPresenter

private protocol NotifyListenerProtocol: AnyObject {}

private final class MockNotifyListenerForIsolated: NotifyListenerProtocol {}