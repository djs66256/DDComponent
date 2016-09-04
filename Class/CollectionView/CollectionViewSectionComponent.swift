//
//  CollectionViewSectionComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for 1 section and many rows
public class CollectionViewSectionComponent: NSObject, CollectionViewComponent {
    public weak var collectionView: UICollectionView?
    public var section: Int = 0
    public var item: Int = 0
    
    public func prepareCollectionView() {
    }
    
    public func reloadIndexPath() {
    }
    
    public func reloadData() {
        self.collectionView?.reloadSections(NSIndexSet(index: section))
    }
    
    public final func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assert(false, "Must override!!!")
        return UICollectionViewCell()
    }
}

// section component combined with header and footer
public class CollectionViewHeaderAndFooterSectionComponent: CollectionViewSectionComponent {
    public var header: CollectionViewComponent? {
        didSet {
            header?.collectionView = collectionView
            header?.item = item
            header?.section = section
        }
    }
    public var footer: CollectionViewComponent? {
        didSet {
            footer?.collectionView = collectionView
            footer?.item = item
            footer?.section = section
        }
    }
    public var headerAndFooter: CollectionViewComponent? {
        didSet {
            headerAndFooter?.collectionView = collectionView
            headerAndFooter?.item = item
            headerAndFooter?.section = section
        }
    }
    
    public override var collectionView: UICollectionView? {
        didSet {
            header?.collectionView = collectionView
            footer?.collectionView = collectionView
            headerAndFooter?.collectionView = collectionView
        }
    }
    
    public override func reloadIndexPath() {
        super.reloadIndexPath()
        header?.item = item
        footer?.item = item
        headerAndFooter?.item = item
        
        header?.section = section
        footer?.section = section
        headerAndFooter?.section = section
    }
    
    public override func prepareCollectionView() {
        super.prepareCollectionView()
        header?.prepareCollectionView()
        footer?.prepareCollectionView()
        headerAndFooter?.prepareCollectionView()
    }
    
    public override func reloadData() {
        reloadIndexPath()
        super.reloadData()
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let header = header {
                if header.respondsToSelector(#selector(CollectionViewComponent.collectionView(_:viewForSupplementaryElementOfKind:atIndexPath:))) {
                    return header.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
                }
            }
        }
        if kind == UICollectionElementKindSectionFooter {
            if let footer = footer {
                if footer.respondsToSelector(#selector(CollectionViewComponent.collectionView(_:viewForSupplementaryElementOfKind:atIndexPath:))) {
                    return footer.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
                }
            }
        }
        if let hf = headerAndFooter {
            if hf.respondsToSelector(#selector(CollectionViewComponent.collectionView(_:viewForSupplementaryElementOfKind:atIndexPath:))) {
                return hf.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
            }
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let header = header {
            if header.respondsToSelector(#selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                return header.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
            }
        }
        if let hf = headerAndFooter {
            if hf.respondsToSelector(#selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                return hf.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
            }
        }
        return CGSize.zero
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let footer = footer {
            if footer.respondsToSelector(#selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                return footer.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
            }
        }
        if let hf = headerAndFooter {
            if hf.respondsToSelector(#selector(CollectionViewComponent.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                return hf.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
            }
        }
        return CGSize.zero
    }
    
}

// for many item components
public class CollectionViewItemGroupComponent: CollectionViewHeaderAndFooterSectionComponent {
    public var subComponents = [CollectionViewComponent]() {
        didSet {
            subComponents.forEach { (comp) in
                comp.collectionView = collectionView
            }
            reloadIndexPath()
        }
    }
    
    public override var collectionView: UICollectionView? {
        didSet {
            subComponents.forEach { (comp) in
                comp.collectionView = collectionView
            }
        }
    }
    
    public override func reloadIndexPath() {
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
    
    public override func prepareCollectionView() {
        super.prepareCollectionView()
        
        for component in subComponents {
            component.prepareCollectionView()
        }
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 0
        for comp in subComponents {
            number += comp.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return number
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.subComponents[itemWithRawItem(indexPath.item)].collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        }
        return CGSize.zero
    }
    
    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, shouldHighlightItemAtIndexPath: indexPath)
        }
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didHighlightItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didUnhighlightItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, shouldSelectItemAtIndexPath: indexPath)
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, shouldDeselectItemAtIndexPath: indexPath)
        }
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didSelectItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didDeselectItemAtIndexPath: indexPath)
        }
    }
    
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:willDisplayCell:forItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:atIndexPath:))) {
            return comp.collectionView!(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, atIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingCell:forItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didEndDisplayingCell: cell, forItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[itemWithRawItem(indexPath.item)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:))) {
            return comp.collectionView!(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, atIndexPath: indexPath)
        }
    }
}
