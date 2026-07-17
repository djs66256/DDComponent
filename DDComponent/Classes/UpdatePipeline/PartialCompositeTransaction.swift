//
//  PartialCompositeTransaction.swift
//  DDComponent
//
//  Created by daniel on 2024/1/6.
//

import Foundation
import UIKit

extension ViewPresentable {
    fileprivate var nearestItemPresenter: CollectionItemPresentable? {
        var p: ViewPresentable? = self
        while p != nil {
            if let itemPresenter = p as? CollectionItemPresentable {
                return itemPresenter
            }
            p = p!.superPresenter
        }
        return nil
    }
}

@MainActor
final class PartialCompositeTransaction: CompositeTransaction, @unchecked Sendable {
    
    private struct PresenterStore: Hashable {
        var presenter: CollectionItemPresentable
        init(_ presenter: CollectionItemPresentable) {
            self.presenter = presenter
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.presenter == rhs.presenter
        }
        var hashValue: Int {
            return presenter.hashValue
        }
        func hash(into hasher: inout Hasher) {
            presenter.hash(into: &hasher)
        }
    }
    private struct SectionPresenterStore: Hashable {
        var presenter: CollectionSectionPresentable
        init(_ presenter: CollectionSectionPresentable) {
            self.presenter = presenter
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.presenter == rhs.presenter
        }
        var hashValue: Int {
            return presenter.hashValue
        }
        func hash(into hasher: inout Hasher) {
            presenter.hash(into: &hasher)
        }
    }
    
    private var invalidateContentSizePresenters = Set<PresenterStore>()
    private var invalidateContentSizeSectionPresenters = Set<SectionPresenterStore>()
    
    func merge(_ other: PartialCompositeTransaction) {
        merge(other as CompositeTransaction)
        invalidateContentSizePresenters.formUnion(other.invalidateContentSizePresenters)
        invalidateContentSizeSectionPresenters.formUnion(other.invalidateContentSizeSectionPresenters)
    }
    
    override func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        if context.invalidateDataSource {
            if let section = presenter as? CollectionSectionPresentable {
                // When section invalidate content size, we need to update supplementaries size.
                // And items size will update by differ results which are inserted.
                invalidateContentSizeSectionPresenters.insert(SectionPresenterStore(section))
            }
        }
        
        if context.invalidateContentSize {
            // Sub presenter may invalidate content size, we need to find the item presenter it attached to.
            if let item = presenter.nearestItemPresenter {
                invalidateContentSizePresenters.insert(PresenterStore(item))
            }
        }
        super.markDirty(presenter: presenter, context: context, completion)
    }
    
    func invalidateContentSize(of section: Engine.DataSource.Section) {
        for p in section.items {
            invalidateContentSizePresenters.insert(PresenterStore(p.typePresenter))
        }
        for (_, supplies) in section.supplementaries {
            for p in supplies {
                invalidateContentSizePresenters.insert(PresenterStore(p.typePresenter))
            }
        }
    }
    
    func invalidateContentSize(of item: Engine.DataSource.Item) {
        invalidateContentSizePresenters.insert(PresenterStore(item.typePresenter))
    }
    
    func collectInvalidatedContentSizeItemPresenter() -> [ViewPresentable] {
        var presenters = invalidateContentSizePresenters.map({ $0.presenter })
        for presenter in invalidateContentSizeSectionPresenters {
            for (_, ps) in presenter.presenter.supplementaries {
                presenters.append(contentsOf: ps)
            }
        }
        invalidateContentSizePresenters.removeAll()
        invalidateContentSizeSectionPresenters.removeAll()
        return presenters
    }
}
