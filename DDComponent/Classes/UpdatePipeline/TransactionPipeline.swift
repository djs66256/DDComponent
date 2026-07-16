//
//  TransactionPipeline.swift
//  DDComponent
//
//  Created by daniel on 2024/1/6.
//

import Foundation
import UIKit

@MainActor
class TransactionPipeline: ViewUpdatePipeline {
    
    weak var superPipeline: ViewUpdatePipeline?
    weak var rootView: UIView?
    weak var rootPresenter: ViewPresentable?
    
    private lazy var globalPipeline = GlobalViewUpdatePipeline.shared
    
    fileprivate var transaction = CompositeTransaction()
    private var isUpdating = false
    private var isDestroyed = false
    
    init(presenter: ViewPresentable, view: UIView? = nil) {
        self.rootPresenter = presenter
        self.rootView = view
    }
    
    func destroy() {
        isDestroyed = true
    }
    
    func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        guard !isDestroyed else { return }
        
        if context.isBindingView {
            presenter.updateView(context: context)
            completion?()
            return
        }
        
        if context.invalidateSuperPresenterContentSize {
            if let superPipeline, let superPresenter = self.rootPresenter?.superPresenter {
                superPipeline.markDirty(presenter: superPresenter, context: context, nil)
            }
            // Invalidate super content size do not need update view, just pass it to super pipeline.
            return
        }
        
        Logger.log("<TransactionPipeline> mark dirty: \(presenter), updating: \(isUpdating)")
        
        transaction.markDirty(presenter: presenter, context: context, completion)
        
        if !isUpdating {
            // When bind view, update view immediately.
            if context.isBindingView {
                if let transaction = transaction.remove(for: presenter) {
                    transaction.updateView()
                    transaction.layoutViewIfNeeded()
                    transaction.complete()
                }
            }
            else {
                // When during updating, should not mark dirty, as it will collect it immediately.
                // Notify global pipeline to update it.
                globalPipeline.markDirty(self)
            }
        }
    }
    
    func updateViewPresenterIfNeeded(_ presenter: ViewPresentable) {
        guard !isDestroyed else { return }
        
        if let transaction = transaction.remove(for: presenter) {
            transaction.updateView()
            transaction.layoutViewIfNeeded()
            transaction.complete()
        }
    }
    
    func updateViewIfNeeded(synchronize: Bool) {
        guard !isDestroyed else { return }
        guard transaction.isDirty else { return }
        
        Logger.log("<TransactionPipeline> update view: synchronize \(synchronize)")
        
        let transaction = doUpdateViewRecursively()
        transaction.layoutViewIfNeeded()
        transaction.complete()
    }
    
    private func doUpdateViewRecursively() -> CompositeTransaction {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
        var finalTransaction = CompositeTransaction()
        // It may mark dirty during update view. Collect them until no updation.
        while self.transaction.isDirty {
            var transaction = self.transaction
            self.transaction = CompositeTransaction()
            
            transaction.updateView()
            finalTransaction.merge(transaction)
        }
        
        return finalTransaction
    }
}


class DryRunTransactionPipeline : TransactionPipeline {
    
    override func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        var context = ViewUpdateContext()
        context.isDryRun = true
        context.layoutImmediately = true
        
        transaction.markDirty(presenter: presenter, context: context, completion)
    }
}
