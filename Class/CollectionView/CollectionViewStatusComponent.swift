//
//  CollectionViewStatusComponent.swift
//  Component
//
//  Created by daniel on 16/9/24.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open
class CollectionViewStatusComponent: CollectionViewBaseComponent {
    private var stateStore = [ComponentState: CollectionViewBaseComponent]()
    
    public var state: ComponentState? {
        didSet {
            if oldValue != state {
                self.reloadData()
            }
        }
    }
    
    open override func reloadData() {
        self.collectionView?.reloadData()
    }
    
    public func set(_ component: CollectionViewBaseComponent, for state: ComponentState) {
        stateStore[state] = component
    }
    
    public func component(for state: ComponentState) -> CollectionViewBaseComponent? {
        return stateStore[state]
    }
    
    // MARK: override
    private func currentComponent() -> CollectionViewBaseComponent? {
        if let state = state {
            return component(for: state)
        }
        return nil
    }
    
    // MARK: DataSource
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let comp = currentComponent() {
            return comp.numberOfSections(in: collectionView)
        }
        return 0
    }
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return 0
    }
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, cellForItemAt: indexPath)
        }
        return UICollectionViewCell()
    }
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        return UICollectionReusableView()
    }
    
    // MARK: Delegate
    public override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, shouldHighlightItemAt: indexPath)
        }
        return true
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, didHighlightItemAt: indexPath)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, didUnhighlightItemAt: indexPath)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, shouldSelectItemAt: indexPath)
        }
        return true
    }
    
    public override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, shouldDeselectItemAt: indexPath)
        }
        return true
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, didDeselectItemAt: indexPath)
        }
    }
    
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
        }
    }
    
    
    public override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
        }
        return false
    }
    
    public override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
        return false
    }
    
    public override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if let comp = currentComponent() {
            comp.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, transitionLayoutForOldLayout: fromLayout, newLayout: toLayout)
        }
        return super.collectionView(collectionView, transitionLayoutForOldLayout: fromLayout, newLayout: toLayout)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
        }
        return super.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
        }
        return super.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
        }
        return super.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
        }
        return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let comp = currentComponent() {
            return comp.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        }
        return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
    }
}
