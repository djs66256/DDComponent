//
//  ViewUpdateContextTests.swift
//  DDComponent_Tests
//

import XCTest
@testable import DDComponent

// MARK: - Tests

@MainActor
final class ViewUpdateContextTests: XCTestCase {

    // MARK: - Merge: Boolean OR Logic

    func testMerge_invalidateLayout_ORLogic() {
        var ctx1 = ViewUpdateContext()
        ctx1.invalidateLayout = true

        var ctx2 = ViewUpdateContext()
        ctx2.invalidateLayout = false

        ctx1.merge(ctx2)
        XCTAssertTrue(ctx1.invalidateLayout)
    }

    func testMerge_invalidateConstraints_ORLogic() {
        var ctx1 = ViewUpdateContext()
        ctx1.invalidateConstraints = false

        var ctx2 = ViewUpdateContext()
        ctx2.invalidateConstraints = true

        ctx1.merge(ctx2)
        XCTAssertTrue(ctx1.invalidateConstraints)
    }

    func testMerge_updateViewImmediately_ORLogic() {
        var ctx1 = ViewUpdateContext()
        ctx1.updateViewImmediately = false

        var ctx2 = ViewUpdateContext()
        ctx2.updateViewImmediately = true

        ctx1.merge(ctx2)
        XCTAssertTrue(ctx1.updateViewImmediately)
    }

    // MARK: - Merge: Animated AND Logic

    func testMerge_animated_ANDLogic() {
        var ctx1 = ViewUpdateContext()
        ctx1.animated = true

        var ctx2 = ViewUpdateContext()
        ctx2.animated = false

        ctx1.merge(ctx2)
        // animated uses AND logic: true && false = false
        XCTAssertFalse(ctx1.animated)
    }

    func testMerge_animated_bothTrue() {
        var ctx1 = ViewUpdateContext()
        ctx1.animated = true

        var ctx2 = ViewUpdateContext()
        ctx2.animated = true

        ctx1.merge(ctx2)
        XCTAssertTrue(ctx1.animated)
    }

    // MARK: - Merge: Force Disable Animation

    func testMerge_forceDisableAnimation_ORLogic() {
        var ctx1 = ViewUpdateContext()
        ctx1.forceDisableAnimation = false

        var ctx2 = ViewUpdateContext()
        ctx2.forceDisableAnimation = true

        ctx1.merge(ctx2)
        XCTAssertTrue(ctx1.forceDisableAnimation)
    }

    // MARK: - Merge: Data Source

    func testMerge_invalidateDataSource_ORLogic() {
        var ctx1 = ViewUpdateContext()
        ctx1.invalidateDataSource = false

        var ctx2 = ViewUpdateContext()
        ctx2.invalidateDataSource = true

        ctx1.merge(ctx2)
        XCTAssertTrue(ctx1.invalidateDataSource)
    }

    // MARK: - Merge: Infos

    func testMerge_infos_latterWins() {
        var ctx1 = ViewUpdateContext()
        ctx1.infos["key"] = "value1"

        var ctx2 = ViewUpdateContext()
        ctx2.infos["key"] = "value2"

        ctx1.merge(ctx2)
        XCTAssertEqual(ctx1.infos["key"] as? String, "value2")
    }

    // MARK: - bindView

    func testBindView_setsIsBindingView() {
        var context = ViewUpdateContext()
        context.bindView()

        XCTAssertTrue(context.isBindingView)
    }

    // MARK: - reloadData

    func testReloadData_setsInvalidateDataSource() {
        var context = ViewUpdateContext()
        context.reloadData()

        XCTAssertTrue(context.invalidateDataSource)
    }

    // MARK: - Dry Run

    func testDryRun_static() {
        let context = ViewUpdateContext.dryRun
        XCTAssertTrue(context.isDryRun)
    }
}