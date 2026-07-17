//
//  CollectionPresenterTests.swift
//  DDComponent_Tests
//

import XCTest
import UIKit
@testable import DDComponent

// MARK: - Mock Item View

private final class MockItemView: UIView {}

// MARK: - Mock Item Presenter

private final class MockCollectionItemPresenter: CollectionItemPresenter<MockItemView> {
    var onBindViewCalled = false
    var onUpdateCalled = false

    override func onBindView(_ view: MockItemView) {
        super.onBindView(view)
        onBindViewCalled = true
    }

    override func onUpdate(view: MockItemView, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        onUpdateCalled = true
    }
}

// MARK: - Tests

@MainActor
final class CollectionPresenterTests: XCTestCase {

    // MARK: - CollectionSectionPresenter: setItems

    func testCollectionSection_setItems_shouldAddChildren() {
        let section = CollectionSectionPresenter()
        let item1 = MockCollectionItemPresenter()
        let item2 = MockCollectionItemPresenter()

        section.setItems([item1, item2])

        XCTAssertEqual(section.items.count, 2)
        XCTAssertTrue(section.children.contains { $0 === item1 })
        XCTAssertTrue(section.children.contains { $0 === item2 })
    }

    func testCollectionSection_setItems_shouldRemoveOldItems() {
        let section = CollectionSectionPresenter()
        let item1 = MockCollectionItemPresenter()
        let item2 = MockCollectionItemPresenter()
        section.setItems([item1, item2])

        let item3 = MockCollectionItemPresenter()
        section.setItems([item3])

        XCTAssertEqual(section.items.count, 1)
        XCTAssertTrue(section.children.contains { $0 === item3 })
        XCTAssertFalse(section.children.contains { $0 === item1 })
        XCTAssertFalse(section.children.contains { $0 === item2 })
    }

    func testCollectionSection_setItems_shouldNotDuplicateChildren() {
        let section = CollectionSectionPresenter()
        let item1 = MockCollectionItemPresenter()

        section.setItems([item1])
        section.setItems([item1])

        XCTAssertEqual(section.items.count, 1)
    }

    // MARK: - CollectionSectionPresenter: Supplementaries

    func testCollectionSection_setSupplementary_shouldAddChildren() {
        let section = CollectionSectionPresenter()
        let supplementary = MockCollectionItemPresenter()

        section.setSupplementary("header", [supplementary])

        XCTAssertEqual(section.supplementaries["header"]?.count, 1)
        XCTAssertTrue(section.children.contains { $0 === supplementary })
    }

    func testCollectionSection_removeSupplementary_shouldRemoveChildren() {
        let section = CollectionSectionPresenter()
        let supplementary = MockCollectionItemPresenter()

        section.setSupplementary("header", [supplementary])
        section.removeSupplementary("header")

        XCTAssertNil(section.supplementaries["header"])
        XCTAssertFalse(section.children.contains { $0 === supplementary })
    }

    func testCollectionSection_setSupplementary_replaceOld() {
        let section = CollectionSectionPresenter()
        let oldSuppl = MockCollectionItemPresenter()
        let newSuppl = MockCollectionItemPresenter()

        section.setSupplementary("header", [oldSuppl])
        section.setSupplementary("header", [newSuppl])

        XCTAssertEqual(section.supplementaries["header"]?.count, 1)
        XCTAssertFalse(section.children.contains { $0 === oldSuppl })
        XCTAssertTrue(section.children.contains { $0 === newSuppl })
    }

    // MARK: - CollectionPresenter: setSections

    func testCollectionPresenter_setSections_shouldAddChildren() {
        let presenter = CollectionPresenter<Void>()
        let section1 = CollectionSectionPresenter()
        let section2 = CollectionSectionPresenter()

        presenter.setSections([section1, section2])

        XCTAssertEqual(presenter.sections.count, 2)
        XCTAssertTrue(presenter.children.contains { $0 === section1 })
        XCTAssertTrue(presenter.children.contains { $0 === section2 })
    }

    func testCollectionPresenter_setSections_shouldRemoveOldSections() {
        let presenter = CollectionPresenter<Void>()
        let section1 = CollectionSectionPresenter()
        let section2 = CollectionSectionPresenter()
        presenter.setSections([section1, section2])

        let section3 = CollectionSectionPresenter()
        presenter.setSections([section3])

        XCTAssertEqual(presenter.sections.count, 1)
        XCTAssertTrue(presenter.children.contains { $0 === section3 })
        XCTAssertFalse(presenter.children.contains { $0 === section1 })
        XCTAssertFalse(presenter.children.contains { $0 === section2 })
    }

    // MARK: - CollectionItemPresenter: Shadow Presenter

    func testCollectionItemPresenter_shadowPresenter_bindViewDelegates() {
        let item = MockCollectionItemPresenter()
        let shadow = CollectionItemPresenter<MockItemView>.ShadowPresenter()
        let view = MockItemView()

        item.onBindReusablePresenter(shadow)
        shadow.bindView(view)

        XCTAssertTrue(item.onBindViewCalled)
    }

    func testCollectionItemPresenter_shadowPresenter_onUnbindClearsSource() {
        let item = MockCollectionItemPresenter()
        let shadow = CollectionItemPresenter<MockItemView>.ShadowPresenter()
        item.onBindReusablePresenter(shadow)

        item.onUnbindReusablePresenter(shadow)

        XCTAssertNil(shadow.shadowSource)
    }

    // MARK: - SuperPresenter

    func testCollectionSection_itemsHaveSuperPresenter() {
        let section = CollectionSectionPresenter()
        let item = MockCollectionItemPresenter()

        section.setItems([item])

        XCTAssertTrue(item.superPresenter === section)
    }

    func testCollectionPresenter_sectionsHaveSuperPresenter() {
        let presenter = CollectionPresenter<Void>()
        let section = CollectionSectionPresenter()

        presenter.setSections([section])

        XCTAssertTrue(section.superPresenter === presenter)
    }
}
