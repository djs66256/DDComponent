//
//  CollectionViewSectionComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for 1 section and many rows
open class CollectionViewSectionComponent: CollectionViewBaseComponent {
    open var sectionInset: UIEdgeInsets?
    open var minimumInteritemSpacing: CGFloat?
    open var minimumLineSpacing: CGFloat?
    public func sectionInset(_ inset: UIEdgeInsets) -> Self {
        self.sectionInset = inset
        return self
    }
    public func minimumInteritemSpacing(_ itemSpacing: CGFloat) -> Self {
        self.minimumInteritemSpacing = itemSpacing
        return self
    }
    public func minimumLineSpacing(_ lineSpacing: CGFloat) -> Self {
        self.minimumLineSpacing = lineSpacing
        return self
    }
    
    open override func reloadData() {
        if let collectionView = self.collectionView {
            let count = numberOfSections(in: collectionView)
            collectionView.reloadSections(IndexSet(integersIn: section..<(section+count)))
        }
    }
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(false, "Must override!!!")
        return UICollectionViewCell()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let sectionInset = sectionInset {
            return sectionInset
        }
        else {
            return super.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let lineSpacing = minimumLineSpacing {
            return lineSpacing
        }
        else {
            return super.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let itemSpacing = minimumInteritemSpacing {
            return itemSpacing
        }
        else {
            return super.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
        }
    }
}

// section component combined with header and footer
open class CollectionViewHeaderAndFooterSectionComponent: CollectionViewSectionComponent {
    open var headerComponent: CollectionViewComponent? {
        didSet {
            headerComponent?.superComponent = self
            if self.collectionView != nil {
                headerComponent?.prepareCollectionView()
            }
        }
    }
    open var footerComponent: CollectionViewComponent? {
        didSet {
            footerComponent?.superComponent = self
            if self.collectionView != nil {
                footerComponent?.prepareCollectionView()
            }
        }
    }
    open var headerFooterComponent: CollectionViewComponent? {
        didSet {
            headerFooterComponent?.superComponent = self
            if self.collectionView != nil {
                headerFooterComponent?.prepareCollectionView()
            }
        }
    }
    
    open override func prepareCollectionView() {
        super.prepareCollectionView()
        if self.collectionView != nil {
            headerComponent?.prepareCollectionView()
            footerComponent?.prepareCollectionView()
            headerFooterComponent?.prepareCollectionView()
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let header = headerComponent {
                return header.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
            }
        }
        if kind == UICollectionElementKindSectionFooter {
            if let footer = footerComponent {
                return footer.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
            }
        }
        if let hf = headerFooterComponent {
            return hf.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        return UICollectionReusableView()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let header = (headerComponent ?? headerFooterComponent) {
            return header.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
        }
        return CGSize.zero
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let footer = (footerComponent ?? headerFooterComponent) {
            return footer.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        }
        return CGSize.zero
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
    }
}

// for many item components
open class CollectionViewItemGroupComponent: CollectionViewHeaderAndFooterSectionComponent {
    open var subComponents = [CollectionViewBaseComponent]() {
        didSet {
            let shouldPrepare = self.collectionView != nil
            subComponents.forEach { (comp) in
                comp.superComponent = self
                if shouldPrepare {
                    comp.prepareCollectionView()
                }
            }
        }
    }
    
    open override func prepareCollectionView() {
        super.prepareCollectionView()
        if self.collectionView != nil {
            for component in subComponents {
                component.prepareCollectionView()
            }
        }
    }
    
    open override func firstSection(ofSubComponent: CollectionViewComponent) -> Int {
        return section
    }
    open override func firstItem(ofSubComponent: CollectionViewComponent) -> Int {
        var item = self.item
        if let collectionView = collectionView {
            let section = self.section
            for comp in subComponents {
                if comp === ofSubComponent {
                    return item
                }
                else {
                    item += comp.collectionView(collectionView, numberOfItemsInSection: section)
                }
            }
        }
        return item
    }
    
    private func component(atItem: Int) -> CollectionViewBaseComponent? {
        if let collectionView = collectionView {
            var item = self.item
            let section = self.section
            for comp in subComponents {
                let count = comp.collectionView(collectionView, numberOfItemsInSection: section)
                if item <= atItem && item+count > atItem {
                    return comp
                }
                item += count
            }
        }
        return nil
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 0
        for comp in subComponents {
            number += comp.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return number
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, cellForItemAt: indexPath)
        }
        else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, shouldHighlightItemAt: indexPath)
        }
        return super.collectionView(collectionView, shouldHighlightItemAt: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            comp.collectionView(collectionView, didHighlightItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            comp.collectionView(collectionView, didUnhighlightItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, shouldSelectItemAt: indexPath)
        }
        return true
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, shouldDeselectItemAt: indexPath)
        }
        return true
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            comp.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            comp.collectionView(collectionView, didDeselectItemAt: indexPath)
        }
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let comp = component(atItem: indexPath.item) {
            return comp.collectionView(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
        }
    }
}
