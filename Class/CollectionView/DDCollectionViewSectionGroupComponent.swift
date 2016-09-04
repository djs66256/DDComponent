//
//  DDCollectionViewSectionGroupComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for many section components
public class DDCollectionViewSectionGroupComponent: NSObject, DDCollectionViewComponent {
    public var subComponents = [DDCollectionViewComponent]() {
        didSet {
            subComponents.forEach { (comp) in
                comp.collectionView = collectionView
            }
            reloadIndexPath()
        }
    }
    
    public weak var collectionView: UICollectionView? {
        didSet {
            for comp in subComponents {
                comp.collectionView = collectionView
            }
        }
    }
    public var section: Int = 0
    public var item: Int {
        get {
            return 0
        }
        set {}
    }
    
    public func reloadIndexPath() {
        if let collectionView = collectionView {
            var s = section
            for comp in subComponents {
                comp.section = s
                s += comp.numberOfSectionsInCollectionView!(collectionView)
                comp.reloadIndexPath()
            }
        }
    }
    
    public func prepareCollectionView() {
        for component in subComponents {
            component.prepareCollectionView()
        }
    }
    
    public func reloadData() {
        let number = numberOfSectionsInCollectionView(self.collectionView!)
        let sections = NSIndexSet(indexesInRange: NSRange(location: section, length: number))
        self.collectionView!.reloadSections(sections)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        var number = 0
        for comp in subComponents {
            number += comp.numberOfSectionsInCollectionView!(collectionView)
        }
        return number
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subComponents[sectionWithRawSection(section)].collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return subComponents[sectionWithRawSection(indexPath.section)].collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    
    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, shouldHighlightItemAtIndexPath: indexPath)
        }
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didHighlightItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didUnhighlightItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, shouldSelectItemAtIndexPath: indexPath)
        }
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, shouldDeselectItemAtIndexPath: indexPath)
        }
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didSelectItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didDeselectItemAtIndexPath: indexPath)
        }
    }
    
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:willDisplayCell:forItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:atIndexPath:))) {
            return comp.collectionView!(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, atIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingCell:forItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, didEndDisplayingCell: cell, forItemAtIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        let comp: UICollectionViewDelegate = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:))) {
            return comp.collectionView!(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, atIndexPath: indexPath)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[sectionWithRawSection(indexPath.section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAtIndexPath:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        }
        return CGSize.zero
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[sectionWithRawSection(section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAtIndex:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: section)
        }
        return UIEdgeInsetsZero
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[sectionWithRawSection(section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAtIndex:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: section)
        }
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[sectionWithRawSection(section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAtIndex:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: section)
        }
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[sectionWithRawSection(section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
        }
        return CGSize.zero
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let comp: UICollectionViewDelegateFlowLayout = subComponents[sectionWithRawSection(section)]
        if comp.respondsToSelector(#selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) {
            return comp.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        }
        return CGSize.zero
    }
}

public class DDCollectionViewRootComponent: DDCollectionViewSectionGroupComponent {
    
    public override var subComponents: [DDCollectionViewComponent] {
        didSet {
            subComponents.forEach { (comp) in
                comp.collectionView = collectionView
            }
            reloadIndexPath()
            prepareCollectionView()
        }
    }
    
    public init(collectionView: UICollectionView?, bind: Bool = true) {
        super.init()
        self.collectionView = collectionView
        if bind {
            collectionView?.delegate = self
            collectionView?.dataSource = self
        }
    }
    
    public override func reloadData() {
        reloadIndexPath()
        self.collectionView?.reloadData()
    }
}
