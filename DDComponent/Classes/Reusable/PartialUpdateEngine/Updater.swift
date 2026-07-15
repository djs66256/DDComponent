//
//  Engine.swift
//  DDComponent
//
//  Created by daniel on 2022/9/17.
//

import Foundation
import UIKit

enum Engine {
    class Updater: BaseViewUpdatePipeline {
        
        weak var root: CollectionPresentable?
        weak var invalidation: UpdatePipelineInvalidateContentSizeProtocol?
        init(root: CollectionPresentable) {
            self.dataSource = DataSource(root: root)
            super.init(presenter: root)
            self.root = root
        }
        
        var lock = NSLock()
        var dirtyVersion: Int = 0
        var dataSource: DataSource
        
        override func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
            // We use dirtyVersion to figure out whether dirty during async updating.
            lock.lock()
            dirtyVersion += 1
            lock.unlock()
            
            if context.invalidateDataSource, let section = presenter as? CollectionSectionPresentable {
                // When section invalidate content size, we need to update supplementaries size.
                // And items size will update by differ results which are inserted.
                invalidateContentSizeSectionPresenters.insert(SectionPresenterStore(section))
            }
            else if context.invalidateContentSize {
                // Sub presenter may invalidate content size, we need to find the item presenter it attached to.
                if let p = findItemPresenter(presenter) {
                    invalidateContentSizePresenters.insert(PresenterStore(p))
                }
            }
            super.markDirty(presenter: presenter, context: context, completion)
        }
        
        private func findItemPresenter(_ presenter: ViewPresentable) -> CollectionItemPresentable? {
            var p: ViewPresentable? = presenter
            while p != nil {
                if let itemPresenter = p as? CollectionItemPresentable {
                    return itemPresenter
                }
                p = p!.superPresenter
            }
            return nil
        }
        
        // 
        struct PresenterStore: Hashable {
            var presenter: CollectionItemPresentable
            init(_ presenter: CollectionItemPresentable) {
                self.presenter = presenter
            }
            static func == (lhs: Engine.Updater.PresenterStore, rhs: Engine.Updater.PresenterStore) -> Bool {
                lhs.presenter == rhs.presenter
            }
            var hashValue: Int {
                return presenter.hashValue
            }
            func hash(into hasher: inout Hasher) {
                presenter.hash(into: &hasher)
            }
        }
        struct SectionPresenterStore: Hashable {
            var presenter: CollectionSectionPresentable
            init(_ presenter: CollectionSectionPresentable) {
                self.presenter = presenter
            }
            static func == (lhs: Engine.Updater.SectionPresenterStore, rhs: Engine.Updater.SectionPresenterStore) -> Bool {
                lhs.presenter == rhs.presenter
            }
            var hashValue: Int {
                return presenter.hashValue
            }
            func hash(into hasher: inout Hasher) {
                presenter.hash(into: &hasher)
            }
        }
        
        var invalidateContentSizePresenters = Set<PresenterStore>()
        var invalidateContentSizeSectionPresenters = Set<SectionPresenterStore>()
        func doInvalidateContentSize() {
            var presenters = invalidateContentSizePresenters.map({ $0.presenter })
            for presenter in invalidateContentSizeSectionPresenters {
                for (_, ps) in presenter.presenter.supplementaries {
                    presenters.append(contentsOf: ps)
                }
            }
            invalidation?.invalidateContentSize(self, presenters)
            invalidateContentSizePresenters.removeAll()
            invalidateContentSizeSectionPresenters.removeAll()
        }
        
        typealias Section = DataSource.Section
        typealias Item = DataSource.Item
        
        func invalidateContentSize(of section: Section) {
            for p in section.items {
                invalidateContentSizePresenters.insert(PresenterStore(p.typePresenter))
            }
            for (_, supplies) in section.supplementaries {
                for p in supplies {
                    invalidateContentSizePresenters.insert(PresenterStore(p.typePresenter))
                }
            }
        }
        
        
    }
    
    class ListUpdater : Updater, ListViewUpdatePipeline {
        let queue = DispatchQueue(label: "diff")
        let listView: ListUpdateProtocol
//        let collectionView: UICollectionView
        init(root: CollectionPresentable, collectionView: UICollectionView) {
            listView = UICollectionViewUpdateResolver(collectionView: collectionView)
            super.init(root: root)
            rootView = collectionView
        }
        
        init(root: CollectionPresentable, tableView: UITableView) {
            listView = UITableViewUpdateResolver(tableView: tableView)
            super.init(root: root)
            rootView = tableView
        }
        
        override func invokeUpdateView(synchronize: Bool, _ updater: @escaping () -> Void, completion: @escaping () -> Void) {
            let updater = { [weak self] in
                self?.doInvalidateContentSize()
                updater()
            }
            if invalidateDataSource {
                invokeUpdateDataSource(synchronize: synchronize, updater, completion: completion)
            }
            else if invalidateContentSize {
                invokeUpdateLayoutOnly(updater, completion: completion)
            }
            else {
                invokeUpdateCellInternally(updater, completion: completion)
            }
        }
        
        private func invokeUpdateDataSource(synchronize: Bool, _ updater: @escaping () -> Void, completion: @escaping () -> Void) -> Bool {
            guard let newData = collectNewDataSource() else {
                updater()
                completion()
                return false
            }
            let oldData = dataSource
            
            if invokeUpdateDataSourceWithoutDiff(oldData: oldData, newData: newData, updater:updater, completion: completion) {
                return false
            }
            else {
                return invokeUpdateDataSourceWithDiff(synchronize: synchronize, oldData, newData, updater, completion)
            }
        }
        
        private func collectNewDataSource() -> DataSource? {
            guard let root = root else {
                return nil
            }
            
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
        
        private func doDiff(_ oldData: Engine.DataSource, _ newData: Engine.DataSource) -> (Differ.IndexDiffResult, [Differ.IndexPathDiffResult]) {
            let differ = Differ()
            let sectionResult = differ.diff(old: oldData.sections,
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
            return (sectionResult, itemResults)
        }
        
        private func doApplyDiff(oldData: Engine.DataSource,
                                 newData: Engine.DataSource,
                                 diffResults: (Differ.IndexDiffResult, [Differ.IndexPathDiffResult]),
                                 updater: @escaping () -> Void,
                                 _ completion: @escaping () -> Void) {
            let (sectionResult, itemResults) = diffResults
            // remove cache size
            for index in sectionResult.inserts {
                self.invalidateContentSize(of: newData.sections[index])
            }
            for itemDiffer in itemResults {
                for indexPath in itemDiffer.inserts {
                    let p = newData.sections[indexPath.section].items[indexPath.item].typePresenter
                    self.invalidateContentSizePresenters.insert(PresenterStore(p))
                }
            }
            // update & batch update list view
            updater()
            if self.isAnimated {
                self.listView.performBatchUpdates {
                    self.dataSource = newData
                    self.listView.performBatchUpdates(sectionDiffer: sectionResult,
                                                      itemDiffer: itemResults)
                } completion: { _ in
                    completion()
                }
            }
            else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.listView.performBatchUpdates {
                    self.dataSource = newData
                    self.listView.performBatchUpdates(sectionDiffer: sectionResult,
                                                      itemDiffer: itemResults)
                } completion: { _ in
                    completion()
                    CATransaction.commit()
                }
            }
        }
        
        private func invokeUpdateDataSourceWithDiff(synchronize: Bool, _ oldData: Engine.DataSource, _ newData: Engine.DataSource, _ updater: @escaping () -> Void, _ completion: @escaping () -> Void) -> Bool {
            if synchronize {
                let diffResults = doDiff(oldData, newData)
                doApplyDiff(oldData: oldData, newData: newData, diffResults: diffResults, updater: updater, completion)
            }
            else {
                let originDirtyVersion = dirtyVersion
                queue.async {
                    self.lock.lock()
                    let cancel = self.dirtyVersion != originDirtyVersion
                    self.lock.unlock()
                    guard !cancel else {
                        return
                    }
                    
                    let diffResults = self.doDiff(oldData, newData)
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        guard !self.isDestroyed else { return }
                        
                        self.lock.lock()
                        let cancel = self.dirtyVersion != originDirtyVersion
                        self.lock.unlock()
                        guard !cancel else {
                            return
                        }
                        self.doApplyDiff(oldData: oldData, newData: newData, diffResults: diffResults, updater: updater, completion)
                    }
                }
            }
            return true
        }
        
        private func invokeUpdateDataSourceWithoutDiff(oldData: DataSource, newData: DataSource, updater: @escaping () -> Void, completion: @escaping () -> Void) -> Bool {
            let oldSections = oldData.sections
            let newSections = newData.sections
            if oldSections.count == 0 || newSections.count == 0 {
                dataSource = newData
                
                if !newSections.isEmpty {
                    // clear size caches
                    for section in newSections {
                        invalidateContentSize(of: section)
                    }
                }
                
                if forceDisableAnimation {
                    invokeWithoutAnimation({
                        updater()
                        self.listView.reloadData()
                        self.listView.performBatchUpdates({}, completion: { _ in })
                        self.listView.layoutIfNeeded()
                    }, completion: completion)
                }
                else if isAnimated {
                    listView.performBatchUpdates {
                        updater()
                        if oldSections.count == 0 {
                            listView.insertSections(IndexSet(integersIn: 0 ... newSections.count))
                        }
                        else {
                            listView.deleteSections(IndexSet(integersIn: 0 ..< oldSections.count))
                        }
                    } completion: { _ in
                        completion()
                    }
                }
                else {
                    let layoutImmediately = self.layoutImmediately
                    updater()
                    listView.reloadData()
                    listView.performBatchUpdates {
                        
                    } completion: { _ in
                        // TODO: CHECK works OK?
                        completion()
                    }
                    if layoutImmediately {
                        listView.layoutIfNeeded()
                    }
                }
                return true
            }
            return false
        }
        
        private func invokeUpdateLayoutOnly(_ updater: @escaping () -> Void, completion: @escaping () -> Void) {
            let reloader = {
                // MUST invalidate inside batchUpdates, otherwise it has a fade out animation
                self.listView.performBatchUpdates {
                    updater()
                    self.listView.invalidateLayout()
                    self.listView.layoutIfNeeded()
                } completion: { _ in

                }
            }
            if forceDisableAnimation {
                invokeWithoutAnimation(reloader, completion: completion)
            }
            else if isAnimated {
                invokeWithAnimation(reloader, completion: completion)
            }
            else {
                super.invokeUpdateView(synchronize: true, reloader, completion: completion)
            }
        }
        
        private func invokeUpdateCellInternally(_ updater: @escaping () -> Void, completion: @escaping () -> Void) {
            if forceDisableAnimation {
                let enabled = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                updater()
                UIView.setAnimationsEnabled(enabled)
                completion()
            }
            else if isAnimated {
                UIView.animate(withDuration: 0.3) {
                    updater()
                } completion: { _ in
                    completion()
                }

            }
            else {
                super.invokeUpdateView(synchronize: true, updater, completion: completion)
            }
        }
    }
}


