//
//  CollectionViewSectionGroupComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for many section components
open class CollectionViewSectionGroupComponent: CollectionViewBaseComponent {
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
    
    open override func firstSection(ofSubComponent: CollectionViewComponent) -> Int {
        var section = self.section
        if let collectionView = collectionView {
            for comp in subComponents {
                if comp === ofSubComponent {
                    return section
                }
                section += comp.numberOfSections(in: collectionView)
            }
        }
        return section
    }
    
    open override func prepareCollectionView() {
        if self.collectionView != nil {
            for component in subComponents {
                component.prepareCollectionView()
            }
        }
    }
    
    open override func reloadData() {
        if let collectionView = self.collectionView {
            let count = numberOfSections(in: collectionView)
            let sections = IndexSet(integersIn: section..<(section+count))
            collectionView.reloadSections(sections)
        }
    }
    
    private func component(atSection: Int) -> CollectionViewBaseComponent? {
        if let collectionView = self.collectionView {
            var section = self.section
            for comp in subComponents {
                let count = comp.numberOfSections(in: collectionView)
                if section <= atSection && section+count > atSection {
                    return comp
                }
                section += count
            }
        }
        return nil
    }
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        var number = 0
        for comp in subComponents {
            number += comp.numberOfSections(in: collectionView)
        }
        return number
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, numberOfItemsInSection: section)
        }
        else {
            return 0
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, cellForItemAt: indexPath)
        }
        else {
            return UICollectionViewCell()
        }
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let comp = component(atSection: indexPath.section) {
            return comp.collectionView(collectionView, shouldHighlightItemAt: indexPath)
        }
        return true
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, didHighlightItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, didUnhighlightItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let comp = component(atSection: indexPath.section) {
            return comp.collectionView(collectionView, shouldSelectItemAt: indexPath)
        }
        return true
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let comp = component(atSection: indexPath.section) {
            return comp.collectionView(collectionView, shouldDeselectItemAt: indexPath)
        }
        return true
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, didDeselectItemAt: indexPath)
        }
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.collectionView(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let comp = component(atSection: indexPath.section) {
            return comp.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.itemSize
        }
        return CGSize.zero
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
        }
        else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.sectionInset
        }
        return UIEdgeInsets.zero
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
        }
        else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumLineSpacing
        }
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
        }
        else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.minimumInteritemSpacing
        }
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
        }
        else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.headerReferenceSize
        }
        return CGSize.zero
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        }
        else if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.footerReferenceSize
        }
        return CGSize.zero
    }
}

open class CollectionViewRootComponent: CollectionViewSectionGroupComponent {
    
    private var collectionViewInstance: UICollectionView
    open override var collectionView: UICollectionView? {
        get {
            return collectionViewInstance
        }
    }
    
    public init(collectionView: UICollectionView, bind: Bool = true) {
        self.collectionViewInstance = collectionView
        super.init()
        if bind {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    open override func reloadData() {
        self.collectionView?.reloadData()
    }
}
