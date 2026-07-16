//
//  ViewGroupPresenterTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Mock Presenters

private final class TypeBoxPresenterA: ViewPresenter<Void> {
    var value: String = ""
}

private final class TypeBoxPresenterB: ViewPresenter<Void> {
    var count: Int = 0
}

// MARK: - Tests

@MainActor
final class ViewGroupPresenterTests: XCTestCase {

    func testTypeBox_shouldAddChild() {
        let group = IdentifierViewGroupPresenter<Void>()
        let presenter = TypeBoxPresenterA()

        group.typeBox(presenter)

        XCTAssertTrue(group.children.contains { $0 === presenter })
    }

    func testTypeUnbox_shouldReturnRegisteredPresenter() {
        let group = IdentifierViewGroupPresenter<Void>()
        let presenter = TypeBoxPresenterA()

        group.typeBox(presenter)

        let retrieved: TypeBoxPresenterA? = group.typeUnbox()
        XCTAssertTrue(retrieved === presenter)
    }

    func testTypeUnbox_shouldReturnNilForUnregisteredType() {
        let group = IdentifierViewGroupPresenter<Void>()

        let retrieved: TypeBoxPresenterA? = group.typeUnbox()
        XCTAssertNil(retrieved)
    }

    func testTypeBoxLazy_shouldNotCreateImmediately() {
        let group = IdentifierViewGroupPresenter<Void>()
        var created = false

        group.typeBoxLazy { () -> TypeBoxPresenterA in
            created = true
            return TypeBoxPresenterA()
        }

        // Lazy presenter should not be created until first access
        XCTAssertFalse(created)
    }

    func testTypeBoxLazy_shouldCreateOnFirstUnbox() {
        let group = IdentifierViewGroupPresenter<Void>()

        group.typeBoxLazy { TypeBoxPresenterA() }

        let retrieved: TypeBoxPresenterA? = group.typeUnbox()
        XCTAssertNotNil(retrieved)
        XCTAssertTrue(group.children.contains { $0 === retrieved })
    }

    func testRemoveTypeBox_shouldRemoveChild() {
        let group = IdentifierViewGroupPresenter<Void>()
        let presenter = TypeBoxPresenterA()

        group.typeBox(presenter)
        group.removeTypeBox(TypeBoxPresenterA.self)

        XCTAssertFalse(group.children.contains { $0 === presenter })
        let retrieved: TypeBoxPresenterA? = group.typeUnbox()
        XCTAssertNil(retrieved)
    }

    func testMultipleTypeBox_shouldCoexist() {
        let group = IdentifierViewGroupPresenter<Void>()
        let presenterA = TypeBoxPresenterA()
        let presenterB = TypeBoxPresenterB()

        group.typeBox(presenterA)
        group.typeBox(presenterB)

        let retrievedA: TypeBoxPresenterA? = group.typeUnbox()
        let retrievedB: TypeBoxPresenterB? = group.typeUnbox()

        XCTAssertTrue(retrievedA === presenterA)
        XCTAssertTrue(retrievedB === presenterB)
    }

    func testTypeUnboxLazy_shouldReturnExistingBeforeCreating() {
        let group = IdentifierViewGroupPresenter<Void>()
        let presenter = TypeBoxPresenterA()

        group.typeBox(presenter)

        let retrieved: TypeBoxPresenterA? = group.typeUnboxLazy { TypeBoxPresenterA() }
        XCTAssertTrue(retrieved === presenter)
    }
}