//
//  CollectionViewComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public protocol CollectionViewComponent: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var superComponent: CollectionViewComponent? { get set }
    var collectionView: UICollectionView? { get }
    func prepareCollectionView()
    func reloadData()
    
    // for subComponent
    func firstItem(ofSubComponent: CollectionViewComponent) -> Int
    func firstSection(ofSubComponent: CollectionViewComponent) -> Int
}

open class CollectionViewBaseComponent: NSObject, CollectionViewComponent {
    public weak var superComponent: CollectionViewComponent?
    public var collectionView: UICollectionView? {
        get {
            return superComponent?.collectionView
        }
    }
    open var item: Int {
        get {
            return superComponent?.firstItem(ofSubComponent: self) ?? 0
        }
    }
    
    open var section: Int {
        get {
            return superComponent?.firstSection(ofSubComponent: self) ?? 0
        }
    }
    
    open func prepareCollectionView() { }
    open func reloadData() { }
    open func reloadData(animated: Bool) {
        if animated {
            reloadData()
        }
        else {
            UIView.performWithoutAnimation {
                self.reloadData()
            }
        }
    }
    
    // TODO: may return Int?
    open func firstItem(ofSubComponent: CollectionViewComponent) -> Int {
        return 0
    }
    open func firstSection(ofSubComponent: CollectionViewComponent) -> Int {
        return 0
    }
    
    // MARK: DataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(false)
        return UICollectionViewCell()
    }
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    // MARK: Delegate
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) { }
    
    
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) { }
    
    
    public func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.itemSize
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.sectionInset
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumLineSpacing
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumInteritemSpacing
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.headerReferenceSize
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.footerReferenceSize
        }
        return .zero
    }
}

