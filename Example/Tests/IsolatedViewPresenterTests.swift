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
}