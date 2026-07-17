//
//  PartialUpdatePipeline.swift
//  DDComponent
//
//  Created by daniel on 2024/1/6.
//

import Foundation
import UIKit

extension Engine {
    
    class PartialTrasactionPipeline: ListViewUpdatePipeline, @unchecked Sendable {
        @MainActor weak var superPipeline: ViewUpdatePipeline?
        @MainActor private lazy var globalPipeline = GlobalViewUpdatePipeline.shared
        
        @MainActor var dataSource: DataSource
        @MainActor var root: CollectionPresentable?
        @MainActor var rootPresenter: ViewPresentable?
        @MainActor weak var rootView: UIView?
        @MainActor weak var invalidation: UpdatePipelineInvalidateContentSizeProtocol?
        
        @MainActor private var transaction = PartialCompositeTrasaction()
        private var lock = NSLock()
        private var dirtyVersion: Int = 0
        @MainActor private var isUpdating = false
        @MainActor private var isDestroyed = false
        
        private let queue = DispatchQueue(label: "diff")
        @MainActor private let listView: ListUpdateProtocol
        
        @MainActor
        init(root: CollectionPresentable, collectionView: UICollectionView) {
            self.dataSource = DataSource(root: root)
            self.root = root
            self.rootPresenter = root
            self.listView = UICollectionViewUpdateResolver(collectionView: collectionView)
            self.rootView = collectionView
        }
        
        @MainActor
        init(root: CollectionPresentable, tableView: UITableView) {
            self.dataSource = DataSource(root: root)
            self.root = root
            self.rootPresenter = root
            self.listView = UITableViewUpdateResolver(tableView: tableView)
            self.rootView = tableView
        }
        
        @MainActor
        func destroy() {
            isDestroyed = true
        }
        
        @MainActor
        func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
            guard !isDestroyed else { return }
            
            if context.invalidateSuperPresenterContentSize {
                if let superPipeline, let superPresenter = self.root?.superPresenter {
                    var superContext = ViewUpdateContext()
                    superContext.invalidateContentSize = true
                    superContext.animated = context.animated
                    superContext.invalidateSuperPresenterContentSize = true
                    superPipeline.markDirty(presenter: superPresenter, context: superContext, nil)
                }
            }
            
            transaction.markDirty(presenter: presenter, context: context, completion)
            
            Logger.log("<PartialCompositeTrasaction> mark dirty: \(presenter), updating: \(isUpdating), invalidate data source: \(context.invalidateDataSource), invalidate content size: \(context.invalidateContentSize)")
            
            // We use dirtyVersion to figure out whether dirty during async updating.
            if context.invalidateDataSource {
                withLock {
                    dirtyVersion += 1
                }
            }
            
            if !isUpdating {
                // When bind view, update view immediately.
                // We can only update view without reload data source in a UICollectionView/UITableView.
                if context.isBindingView,
                   let transaction = transaction.remove(for: presenter, passing: { !$0.context.invalidateDataSource }) {
                    transaction.updateView()
                    transaction.layoutViewIfNeeded()
                    transaction.complete()
                }
                else {
                    // When during updating, should not mark dirty, as it will collect it immediately.
                    // Notify global pipeline to update it.
                    globalPipeline.markDirty(self)
                }
            }
        }
        
        @MainActor
        func updateViewPresenterIfNeeded(_ presenter: ViewPresentable) {
            guard !isDestroyed else { return }
            
            if transaction.invalidateDataSource || transaction.invalidateContentSize {
                updateViewIfNeeded(synchronize: true)
            }
            else if let transaction = transaction.remove(for: presenter) {
                transaction.updateView()
                transaction.layoutViewIfNeeded()
                transaction.complete()
            }
        }
        
        @MainActor
        func updateViewIfNeeded(synchronize: Bool) {
            guard !isDestroyed else { return }
            guard transaction.isDirty else { return }
            
            // We use dirtyVersion to figure out whether dirty during async updating.
            withLock {
                dirtyVersion += 1
            }
            
            if transaction.invalidateDataSource {
                guard let newData = collectNewDataSource() else { return }
                let oldData = dataSource
                
                if oldData.sections.isEmpty || newData.sections.isEmpty {
                    Logger.log("<PartialCompositeTrasaction> update view: reload data without differ")
                    doReloadDataSourceWithoutDiff(oldData: oldData, newData: newData, synchronize: synchronize)
                }
                else {
                    Logger.log("<PartialCompositeTrasaction> update view: reload data with differ")
                    doReloadDataSourceWithDiff(oldData: oldData, newData: newData, synchronize: synchronize) { finished in
                        // Do nothing
                    }
                }
            }
            else if transaction.invalidateContentSize {
                Logger.log("<PartialCompositeTrasaction> update view: invalidate content size")
                doUpdateListViewLayout(synchronize: synchronize)
            }
            else {
                Logger.log("<PartialCompositeTrasaction> update view: update item")
                doUpdateItemView(synchronize: synchronize)
            }
        }
        
        @MainActor
        private func doUpdateViewRecursively() -> PartialCompositeTrasaction {
            isUpdating = true
            defer {
                isUpdating = false
            }
            
            var finalTransaction = PartialCompositeTrasaction()
            
            var transaction = self.transaction
            self.transaction = PartialCompositeTrasaction()
            
            while transaction.isDirty {
                finalTransaction.merge(transaction)
                transaction.updateView()
                
                if self.transaction.invalidateDataSource {
                    break;
                }
                transaction = self.transaction
                self.transaction = PartialCompositeTrasaction()
            }
            
            let presenters = finalTransaction.collectInvalidatedContentSizeItemPresenter()
            invalidation?.invalidateContentSize(self, presenters)
            
            return finalTransaction
        }
        
        @MainActor
        private func collectNewDataSource() -> DataSource? {
            guard let root = root else {
                return nil
            }
            
            typealias Section = DataSource.Section
            typealias Item = DataSource.Item
            
            let dataSource = DataSource(root: root)
            dataSource.sections = root.sections.map({
                Section(presenter: $0, items: $0.items.map({
                    Item(presenter: $0)
                }), supplementaries: { section in
                    var supplementaries = [String: [Item]]()
                    for (kind, origins) in section.supplementaries {
                        supplementaries[kind] = origins.map({ Item(presenter: $0) })
                    }
                    return supplementaries
                }($0))
            })
            return dataSource
        }
        
        @MainActor
        private func doReloadDataSourceWithoutDiff(oldData: Engine.DataSource,
                                                   newData: Engine.DataSource,
                                                   synchronize: Bool) {
            let oldSections = oldData.sections
            let newSections = newData.sections
            
            // clear size caches
            for section in newSections {
                transaction.invalidateContentSize(of: section)
            }
            
            // update & batch update list view
            let transaction = doUpdateViewRecursively()
            let context = transaction.reloadDataContext
            
            if !context.animated {
                self.dataSource = newData
                self.listView.reloadData()
            }
            performBatchUpdates(with: context, synchronize: synchronize) {
                if context.animated {
                    self.dataSource = newData
                    if oldSections.count == 0 {
                        self.listView.insertSections(IndexSet(integersIn: 0 ... newSections.count))
                    }
                    else {
                        self.listView.deleteSections(IndexSet(integersIn: 0 ..< oldSections.count))
                    }
                }
                transaction.layoutViewIfNeeded()
            } completion: {
                transaction.complete()
            }
        }
        
        @MainActor
        private func doReloadDataSourceWithDiff(oldData: Engine.DataSource,
                                                newData: Engine.DataSource,
                                                synchronize: Bool,
                                                _ completion: @escaping (Bool) -> Void) {
            if synchronize {
                let result = doDiff(oldData: oldData, newData: newData)
                doReloadDataSourceApplyDiff(with: result, synchronize: synchronize)
                completion(true)
            }
            else {
                let originDirtyVersion = withLock { dirtyVersion }
                queue.async { [weak self] in
                    guard let self, self.withLock({ self.dirtyVersion == originDirtyVersion }) else {
                        Logger.log("<PartialCompositeTrasaction> cancel update view: reload data with differ")
                        completion(false)
                        return
                    }
                    
                    let result = self.doDiff(oldData: oldData, newData: newData)

                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        guard self.withLock({ self.dirtyVersion == originDirtyVersion }) else {
                            Logger.log("<PartialCompositeTrasaction> cancel update view: reload data with differ")
                            completion(false)
                            return
                        }
                        guard !self.isDestroyed else { return }

                        self.doReloadDataSourceApplyDiff(with: result, synchronize: synchronize)
                        completion(true)
                    }
                }
            }
        }
        
        private struct DiffResult {
            var oldData: Engine.DataSource
            var newData: Engine.DataSource
            var sectionResult: Differ.IndexDiffResult
            var itemResult: [Differ.IndexPathDiffResult]
        }
        
        private func doDiff(oldData: Engine.DataSource, newData: Engine.DataSource) -> DiffResult {
            let differ = Differ()
            var sectionResult = differ.diff(old: oldData.sections,
                                            new: newData.sections)
            var itemResults: [Differ.IndexPathDiffResult] = []
            for (newIndex, newSection) in newData.sections.enumerated() {
                if let oldIndex = sectionResult.oldIndex(of: newSection) {
                    let oldSection = oldData.sections[oldIndex]
                    let itemResult = differ.diff(oldSection: oldIndex,
                                                 newSection: newIndex,
                                                 oldItems: oldSection.items,
                                                 newItems: newSection.items)
                    itemResults.append(itemResult)
                }
            }
            
            var reloads = IndexSet()
            for (newIndex, newSection) in newData.sections.enumerated() {
                if let oldIndex = sectionResult.oldIndex(of: newSection) {
                    let oldSection = oldData.sections[oldIndex]
                    if !oldSection.areSupplementariesEquals(newSection) {
                        reloads.insert(newIndex)
                    }
                }
            }
            sectionResult.reloads = reloads
            
            return DiffResult(oldData: oldData,
                              newData: newData,
                              sectionResult: sectionResult,
                              itemResult: itemResults)
        }
        
        @MainActor
        private func doReloadDataSourceApplyDiff(with result: DiffResult,
                                                 synchronize: Bool) {
            let (newData, sectionResult, itemResults) = (result.newData, result.sectionResult, result.itemResult)
            // remove cache size
            for index in sectionResult.inserts {
                transaction.invalidateContentSize(of: newData.sections[index])
            }
            for itemDiffer in itemResults {
                for indexPath in itemDiffer.inserts {
                    let item = newData.sections[indexPath.section].items[indexPath.item]
                    transaction.invalidateContentSize(of: item)
                }
            }
            // update & batch update list view
            let transaction = doUpdateViewRecursively()
            let context = transaction.reloadDataContext
            
            performBatchUpdates(with: context, synchronize: synchronize) {
                self.dataSource = newData
                self.listView.performBatchUpdates(sectionDiffer: sectionResult,
                                                  itemDiffer: itemResults)
                transaction.layoutViewIfNeeded()
            } completion: {
                transaction.complete()
            }
        }
        
        @MainActor
        private func doUpdateListViewLayout(synchronize: Bool) {
            let transaction = doUpdateViewRecursively()
            let context = transaction.invalidateContentSizeContext
            
            performBatchUpdates(with: context, synchronize: synchronize) {
                self.listView.invalidateLayout()
                self.listView.layoutIfNeeded()
                transaction.layoutViewIfNeeded()
            } completion: {
                transaction.complete()
            }
        }
        
        @MainActor
        private func doUpdateItemView(synchronize: Bool) {
            let transaction = doUpdateViewRecursively()
            transaction.layoutViewIfNeeded()
            transaction.complete()
        }
        
        @MainActor
        private func performBatchUpdates(with context: ViewUpdateContext,
                                         synchronize: Bool,
                                         updater: @escaping ()->Void,
                                         completion: @escaping () -> Void) {
            if context.forceDisableAnimation {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.listView.performBatchUpdates(updater) { _ in
                    CATransaction.commit()
                    completion()
                }
            }
            else {
                self.listView.performBatchUpdates(updater) { _ in
                    completion()
                }
            }
        }
        
        
        private func withLock<T>(_ closure: () -> T) -> T {
            lock.lock()
            var value = closure()
            lock.unlock()
            return value
        }
    }
    
}
