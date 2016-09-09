//
//  CollectionViewSectionComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for 1 section and many rows
open class CollectionViewSectionComponent: NSObject, CollectionViewComponent {
    open weak var superComponent: CollectionViewComponent?
    open var collectionView: UICollectionView? {
        get {
            return superComponent?.collectionView
        }
    }
    open var section: Int = 0
    open var item: Int = 0
    open var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    
    open func prepareCollectionView() {
    }
    
    open func reloadIndexPath() {
    }
    
    open func reloadData() {
        self.collectionView?.reloadSections(IndexSet(integer: section))
    }
    
    public final func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(false, "Must override!!!")
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
}

// section component combined with header and footer
open class CollectionViewHeaderAndFooterSectionComponent: CollectionViewSectionComponent {
    open var header: CollectionViewComponent? {
        didSet {
            header?.item = item
            header?.section = section
            header?.superComponent = self
        }
    }
    open var footer: CollectionViewComponent? {
        didSet {
            footer?.item = item
            footer?.section = section
            footer?.superComponent = self
        }
    }
    open var headerAndFooter: CollectionViewComponent? {
        didSet {
            headerAndFooter?.item = item
            headerAndFooter?.section = section
            headerAndFooter?.superComponent = self
        }
    }
    
    open override func reloadIndexPath() {
        super.reloadIndexPath()
        header?.item = item
        footer?.item = item
        headerAndFooter?.item = item
        
        header?.section = section
        footer?.section = section
        headerAndFooter?.section = section
    }
    
    open override func prepareCollectionView() {
        super.prepareCollectionView()
        header?.prepareCollectionView()
        footer?.prepareCollectionView()
        headerAndFooter?.prepareCollectionView()
    }
    
    open override func reloadData() {
        reloadIndexPath()
        super.reloadData()
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let header = header {
                if header.responds(to: #selector(CollectionViewComponent.collectionView(_:viewForSupplementaryElementOfKind:at:))) {
                    return header.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
                }
            }
        }
        if kind == UICollectionElementKindSectionFooter {
            if let footer = footer {
                if footer.responds(to: #selector(CollectionViewComponent.collectionView(_:viewForSupplementaryElementOfKind:at:))) {
                    return footer.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
                }
            }
        }
        if let hf = headerAndFooter {
            if hf.responds(to: #selector(CollectionViewComponent.collectionView(_:viewForSupplementaryElementOfKind:at:))) {
                return hf.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
            }
        }
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let header = header {
            if header.responds(to: #selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                return header.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
            }
        }
        if let hf = headerAndFooter {
            if hf.responds(to: #selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                return hf.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
            }
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let footer = footer {
            if footer.responds(to: #selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                return footer.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
            }
        }
        if let hf = headerAndFooter {
            if hf.responds(to: #selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                return hf.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
            }
        }
        return CGSize.zero
    }
    
}

// for many item components
open class CollectionViewItemGroupComponent: CollectionViewHeaderAndFooterSectionComponent {
    open var subComponents = [CollectionViewComponent]() {
        didSet {
            subComponents.forEach { (comp) in
                comp.superComponent = self
            }
            reloadIndexPath()
        }
    }
    
    open override func reloadIndexPath() {
        if let collectionView = collectionView {
            super.reloadIndexPath()
            var i = item
            for comp in subComponents {
                comp.section = section
                comp.item = i
                i += comp.collectionView(collectionView, numberOfItemsInSection: section)
                comp.reloadIndexPath()
            }
        }
    }
    
    open override func prepareCollectionView() {
        super.prepareCollectionView()
        
        for component in subComponents {
            component.prepareCollectionView()
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 0
        for comp in subComponents {
            number += comp.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return number
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.subComponents[item(rawItem: indexPath.item)].collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: IndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:))) {
            return comp.collectionView!(collectionView, shouldHighlightItemAt: indexPath)
        }
        return true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:))) {
            return comp.collectionView!(collectionView, didHighlightItemAt: indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:))) {
            return comp.collectionView!(collectionView, didUnhighlightItemAt: indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: IndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:))) {
            return comp.collectionView!(collectionView, shouldSelectItemAt: indexPath)
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: IndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:))) {
            return comp.collectionView!(collectionView, shouldDeselectItemAt: indexPath)
        }
        return true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:))) {
            return comp.collectionView!(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:))) {
            return comp.collectionView!(collectionView, didDeselectItemAt: indexPath)
        }
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))) {
            return comp.collectionView!(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:))) {
            return comp.collectionView!(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))) {
            return comp.collectionView!(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: IndexPath) {
        let comp: UICollectionViewDelegate = subComponents[item(rawItem: indexPath.item)]
        if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))) {
            return comp.collectionView!(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
        }
    }
}
