//
//  ViewUpdatePipelineBuilder.swift
//  DDComponent
//
//  Created by daniel on 2024/1/7.
//

import Foundation
import UIKit

@MainActor
struct ViewUpdatePipelineBuilder {
    
    static var useNewPipeline: Bool { true }
    
    static func buildDefaultPipeline(presenter: ViewPresentable, view: UIView?) -> ViewUpdatePipeline {
        if useNewPipeline {
            return TransactionPipeline(presenter: presenter, view: view)
        }
        else {
            return DefaultViewUpdatePipeline(presenter: presenter, view: view)
        }
    }
    
    static func buildDryRunPipeline(presenter: ViewPresentable) -> ViewUpdatePipeline {
        if useNewPipeline {
            return DryRunTransactionPipeline(presenter: presenter)
        }
        else {
            return DryRunViewUpdatePipeline(presenter: presenter)
        }
    }
    
    static func buildTableViewPipeline(presenter: CollectionPresentable, tableView: UITableView) -> ListViewUpdatePipeline {
        if useNewPipeline {
            return Engine.PartialTransactionPipeline(root: presenter, tableView: tableView)
        }
        else {
            return Engine.ListUpdater(root: presenter, tableView: tableView)
        }
    }
    
    static func buildCollectionViewPipeline(presenter: CollectionPresentable, collectionView: UICollectionView) -> ListViewUpdatePipeline {
        if useNewPipeline {
            return Engine.PartialTransactionPipeline(root: presenter, collectionView: collectionView)
        }
        else {
            return Engine.ListUpdater(root: presenter, collectionView: collectionView)
        }
    }
}
