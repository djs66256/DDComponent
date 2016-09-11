//
//  CollectionViewSectionGroupComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for many section components
open class CollectionViewSectionGroupComponent: NSObject, CollectionViewComponent {
    open var subComponents = [CollectionViewComponent]() {
        didSet {
            subComponents.forEach { (comp) in
                comp.superComponent = self
            }
        }
    }
    
    open weak var superComponent: CollectionViewComponent?
    open var collectionView: UICollectionView? {
        get {
            return superComponent?.collectionView
        }
    }
    open var section: Int = 0
    open var item: Int {
        get {
            return 0
        }
        set {}
    }
    
    open func reloadIndexPath() {
        if let collectionView = collectionView {
            var s = section
            for comp in subComponents {
                comp.section = s
                s += comp.numberOfSections!(in: collectionView)
                comp.reloadIndexPath()
            }
        }
    }
    
    open func prepareCollectionView() {
        for component in subComponents {
            component.prepareCollectionView()
        }
    }
    
    open func reloadData() {
        let number = numberOfSections(in: self.collectionView!)
        let sections = IndexSet(integersIn: NSRange(location: section, length: number).toRange() ?? 0..<0)
        self.collectionView!.reloadSections(sections)
    }
    
    private func component(atSection: Int) -> CollectionViewComponent? {
        var preComp: CollectionViewComponent?
        for comp in subComponents {
            if let preComp = preComp {
                if preComp.section <= atSection && comp.section > atSection {
                    return preComp
                }
            }
            preComp = comp
        }
        return preComp
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        var number = 0
        for comp in subComponents {
            number += comp.numberOfSections!(in: collectionView)
        }
        return number
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, numberOfItemsInSection: section)
        }
        else {
            return 1
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let comp = component(atSection: section) {
            return comp.collectionView(collectionView, cellForItemAt: indexPath)
        }
        else {
            return UICollectionViewCell()
        }
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:))) {
                return comp.collectionView!(collectionView, shouldHighlightItemAt: indexPath)
            }
        }
        return true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:))) {
                return comp.collectionView!(collectionView, didHighlightItemAt: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:))) {
                return comp.collectionView!(collectionView, didUnhighlightItemAt: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:shouldSelectItemAt:))) {
                return comp.collectionView!(collectionView, shouldSelectItemAt: indexPath)
            }
        }
        return true
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:shouldDeselectItemAt:))) {
                return comp.collectionView!(collectionView, shouldDeselectItemAt: indexPath)
            }
        }
        return true
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:))) {
                return comp.collectionView!(collectionView, didSelectItemAt: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:))) {
                return comp.collectionView!(collectionView, didDeselectItemAt: indexPath)
            }
        }
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))) {
                return comp.collectionView!(collectionView, willDisplay: cell, forItemAt: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:))) {
                return comp.collectionView!(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))) {
                return comp.collectionView!(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let comp: UICollectionViewDelegate = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))) {
                return comp.collectionView!(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let comp: UICollectionViewDelegateFlowLayout = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
                return comp.collectionView!(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            }
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let comp: UICollectionViewDelegateFlowLayout = component(atSection: section) {
            if comp.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))) {
                return comp.collectionView!(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
            }
        }
        return UIEdgeInsets.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let comp: UICollectionViewDelegateFlowLayout = component(atSection: section) {
            if comp.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:))) {
                return comp.collectionView!(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
            }
        }
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let comp: UICollectionViewDelegateFlowLayout = component(atSection: section) {
            if comp.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) {
                return comp.collectionView!(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
            }
        }
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let comp: UICollectionViewDelegateFlowLayout = component(atSection: section) {
            if comp.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                return comp.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
            }
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let comp: UICollectionViewDelegateFlowLayout = component(atSection: section) {
            if comp.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                return comp.collectionView!(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
            }
        }
        return CGSize.zero
    }
}

open class CollectionViewRootComponent: CollectionViewSectionGroupComponent {
    
    open override var subComponents: [CollectionViewComponent] {
        didSet {
            reloadIndexPath()
            prepareCollectionView()
        }
    }
    
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
        reloadIndexPath()
        prepareCollectionView()
        self.collectionView?.reloadData()
    }
}