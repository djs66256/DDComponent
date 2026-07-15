//
//  ViewUpdatePipeline.swift
//  DDComponent
//
//  Created by daniel on 2022/8/31.
//

import Foundation

public protocol ViewUpdatePipeline: AnyObject {
    @MainActor var superPipeline: ViewUpdatePipeline? { get set }
    @MainActor var rootPresenter: ViewPresentable? { get }
    @MainActor func markDirty(presenter: ViewPresentable,
                              context: ViewUpdateContext,
                              _ completion: (() -> Void)?)
    @MainActor func updateViewPresenterIfNeeded(_ presenter: ViewPresentable)
    @MainActor func updateViewIfNeeded(synchronize: Bool)
    
    @MainActor func destroy()
}

@MainActor
protocol UpdatePipelineInvalidateContentSizeProtocol: AnyObject {
    @MainActor func invalidateContentSize(_ pipeline: ViewUpdatePipeline, _ presenters: [ViewPresentable])
}

protocol ListViewUpdatePipeline: ViewUpdatePipeline {
    @MainActor var invalidation: UpdatePipelineInvalidateContentSizeProtocol? { get set }
    @MainActor var dataSource: Engine.DataSource { get }
}

internal struct Logger {
    internal static func log(_ msg: @autoclosure () -> String) {
#if DEBUG && false
        print("Pipeline: \(CFAbsoluteTimeGetCurrent()) \(msg())")
#endif
    }
}
