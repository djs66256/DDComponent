//
//  ListViewUpdateResolver.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation

protocol ListUpdateProtocol {
    typealias IndexDiffResult = Engine.Differ.IndexDiffResult
    typealias IndexPathDiffResult = Engine.Differ.IndexPathDiffResult
    func invalidateLayout()
    func reloadData()
    func layoutIfNeeded()
    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func performBatchUpdates(_ updater: ()->Void, completion: @escaping (Bool)->Void)
    func performBatchUpdates(sectionDiffer: IndexDiffResult, itemDiffer: [IndexPathDiffResult])
}

extension Engine {
    struct UICollectionViewUpdateResolver: ListUpdateProtocol {
        
        let collectionView: UICollectionView
        
        func invalidateLayout() {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        
        func reloadData() {
            collectionView.reloadData()
        }
        
        func layoutIfNeeded() {
            collectionView.layoutIfNeeded()
        }
        
        func insertSections(_ sections: IndexSet) {
            collectionView.insertSections(sections)
        }
        
        func deleteSections(_ sections: IndexSet) {
            collectionView.deleteSections(sections)
        }
        
        func performBatchUpdates(_ updater: () -> Void, completion: @escaping (Bool) -> Void) {
            do {
                try collectionView.performBatchUpdates(updater, completion: completion)
            }
            catch {
                Logger.log("<UICollectionViewUpdateResolver> performBatchUpdates failed: \(error)")
            }
        }
        
        func performBatchUpdates(sectionDiffer: IndexDiffResult, itemDiffer: [IndexPathDiffResult]) {
            for differ in itemDiffer {
                if differ.deletes.count > 0 {
                    collectionView.deleteItems(at: differ.deletes)
                }
                if differ.inserts.count > 0 {
                    collectionView.insertItems(at: differ.inserts)
                }
                for move in differ.moves {
                    collectionView.moveItem(at: move.from, to: move.to)
                }
            }
            if sectionDiffer.deletes.count > 0 {
                collectionView.deleteSections(sectionDiffer.deletes)
            }
            if sectionDiffer.inserts.count > 0 {
                collectionView.insertSections(sectionDiffer.inserts)
            }
            for move in sectionDiffer.moves {
                collectionView.moveSection(move.from, toSection: move.to)
            }
            if !sectionDiffer.reloads.isEmpty {
                collectionView.reloadSections(sectionDiffer.reloads)
            }
        }
        
    }
    
    struct UITableViewUpdateResolver: ListUpdateProtocol {
        
        let tableView: UITableView
        
        func invalidateLayout() {
            tableView.setNeedsLayout()
        }
        
        func reloadData() {
            tableView.reloadData()
        }
        
        func layoutIfNeeded() {
            tableView.layoutIfNeeded()
        }
        
        func insertSections(_ sections: IndexSet) {
            tableView.insertSections(sections, with: .none)
        }
        
        func deleteSections(_ sections: IndexSet) {
            tableView.deleteSections(sections, with: .none)
        }
        
        func performBatchUpdates(_ updater: () -> Void, completion: @escaping (Bool) -> Void) {
            do {
                try tableView.performBatchUpdates(updater, completion: completion)
            }
            catch {
                Logger.log("<UICollectionViewUpdateResolver> performBatchUpdates failed: \(error)")
            }
        }
        
        func performBatchUpdates(sectionDiffer: IndexDiffResult, itemDiffer: [IndexPathDiffResult]) {
            for differ in itemDiffer {
                if differ.deletes.count > 0 {
                    tableView.deleteRows(at: differ.deletes, with: .none)
                }
                if differ.inserts.count > 0 {
                    tableView.insertRows(at: differ.inserts, with: .none)
                }
                for move in differ.moves {
                    tableView.moveRow(at: move.from, to: move.to)
                }
            }
            if sectionDiffer.deletes.count > 0 {
                tableView.deleteSections(sectionDiffer.deletes, with: .none)
            }
            if sectionDiffer.inserts.count > 0 {
                tableView.insertSections(sectionDiffer.inserts, with: .none)
            }
            for move in sectionDiffer.moves {
                tableView.moveSection(move.from, toSection: move.to)
            }
            if !sectionDiffer.reloads.isEmpty {
                tableView.reloadSections(sectionDiffer.reloads, with: .none)
            }
        }
    }
}
