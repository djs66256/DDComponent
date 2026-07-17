//
//  DifferTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Mock EngineViewPresenterReadable

/// A mock that conforms to EngineViewPresenterReadable for testing the Differ.
private struct MockDiffItem: EngineViewPresenterReadable {
    let presenter: ViewPresentable
    let identifier: ObjectIdentifier

    init(_ presenter: ViewPresentable) {
        self.presenter = presenter
        self.identifier = ObjectIdentifier(presenter)
    }
}

// MARK: - Tests

@MainActor
final class DifferTests: XCTestCase {

    // Helper to create unique presenters
    private func makePresenter() -> ViewPresentable {
        return ViewPresenter<Void>()
    }

    // MARK: - Empty to Non-Empty

    func testDiff_emptyToNonEmpty_shouldAllInserts() {
        let differ = Engine.Differ()
        let old: [MockDiffItem] = []
        let new = [MockDiffItem(makePresenter()), MockDiffItem(makePresenter()), MockDiffItem(makePresenter())]

        let result = differ.diff(old: old, new: new)

        XCTAssertEqual(result.inserts.count, 3)
        XCTAssertEqual(result.deletes.count, 0)
        XCTAssertEqual(result.moves.count, 0)
    }

    // MARK: - Non-Empty to Empty

    func testDiff_nonEmptyToEmpty_shouldAllDeletes() {
        let differ = Engine.Differ()
        let old = [MockDiffItem(makePresenter()), MockDiffItem(makePresenter())]
        let new: [MockDiffItem] = []

        let result = differ.diff(old: old, new: new)

        XCTAssertEqual(result.deletes.count, 2)
        XCTAssertEqual(result.inserts.count, 0)
        XCTAssertEqual(result.moves.count, 0)
    }

    // MARK: - Same Order

    func testDiff_sameOrder_shouldNoChanges() {
        let differ = Engine.Differ()
        let a = MockDiffItem(makePresenter())
        let b = MockDiffItem(makePresenter())
        let old = [a, b]
        let new = [a, b]

        let result = differ.diff(old: old, new: new)

        XCTAssertEqual(result.inserts.count, 0)
        XCTAssertEqual(result.deletes.count, 0)
        XCTAssertEqual(result.moves.count, 0)
    }

    // MARK: - Reorder

    func testDiff_reorderItems_shouldDetectMove() {
        let differ = Engine.Differ()
        let a = MockDiffItem(makePresenter())
        let b = MockDiffItem(makePresenter())
        let old = [a, b]
        let new = [b, a]

        let result = differ.diff(old: old, new: new)

        XCTAssertEqual(result.moves.count, 2)
        XCTAssertEqual(result.inserts.count, 0)
        XCTAssertEqual(result.deletes.count, 0)
    }

    // MARK: - Insert

    func testDiff_addItem_shouldDetectInsert() {
        let differ = Engine.Differ()
        let a = MockDiffItem(makePresenter())
        let b = MockDiffItem(makePresenter())
        let c = MockDiffItem(makePresenter())
        let old = [a, b]
        let new = [a, c, b]

        let result = differ.diff(old: old, new: new)

        XCTAssertEqual(result.inserts.count, 1)
        XCTAssertEqual(result.deletes.count, 0)
    }

    // MARK: - Delete

    func testDiff_removeItem_shouldDetectDelete() {
        let differ = Engine.Differ()
        let a = MockDiffItem(makePresenter())
        let b = MockDiffItem(makePresenter())
        let c = MockDiffItem(makePresenter())
        let old = [a, b, c]
        let new = [a, c]

        let result = differ.diff(old: old, new: new)

        XCTAssertEqual(result.deletes.count, 1)
        XCTAssertEqual(result.inserts.count, 0)
    }

    // MARK: - Complex

    func testDiff_complexChanges_insertDeleteMoveCombined() {
        let differ = Engine.Differ()
        let a = MockDiffItem(makePresenter())
        let b = MockDiffItem(makePresenter())
        let c = MockDiffItem(makePresenter())
        let d = MockDiffItem(makePresenter())
        let e = MockDiffItem(makePresenter())

        let old = [a, b, c]
        let new = [b, d, a, e]

        let result = differ.diff(old: old, new: new)

        // Expected: 1 delete (c), 2 inserts (d, e), 2 moves (a, b)
        XCTAssertEqual(result.deletes.count, 1)
        XCTAssertEqual(result.inserts.count, 2)
        XCTAssertEqual(result.moves.count, 2)
    }

    // MARK: - Identical Objects

    func testDiff_identicalObjects_noChanges() {
        let differ = Engine.Differ()
        let a = MockDiffItem(makePresenter())
        let b = MockDiffItem(makePresenter())
        let old = [a, b]
        let new = [a, b]

        let result = differ.diff(old: old, new: new)

        XCTAssertEqual(result.inserts.count, 0)
        XCTAssertEqual(result.deletes.count, 0)
        XCTAssertEqual(result.moves.count, 0)
    }

    // MARK: - IndexPath Diff

    func testDiff_indexPathDiff_sectionOffset() {
        let differ = Engine.Differ()
        let oldItemPresenter = CollectionItemPresenter<UIView>()
        let newItemPresenter = CollectionItemPresenter<UIView>()

        let oldItem = Engine.DataSource.Item(presenter: oldItemPresenter)
        let newItem = Engine.DataSource.Item(presenter: newItemPresenter)

        let result = differ.diff(
            oldSection: 2,
            newSection: 2,
            oldItems: [oldItem],
            newItems: [newItem]
        )

        XCTAssertEqual(result.deletes.count, 1)
        XCTAssertEqual(result.deletes.first?.section, 2)
        XCTAssertEqual(result.inserts.count, 1)
        XCTAssertEqual(result.inserts.first?.section, 2)
    }
}