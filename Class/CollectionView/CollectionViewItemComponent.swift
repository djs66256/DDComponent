//
//  CollectionViewItemComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for 1 section and 1 row
open class CollectionViewItemComponent: NSObject, CollectionViewComponent {
    open weak var superComponent: CollectionViewComponent?
    open var collectionView: UICollectionView? {
        get {
            return superComponent?.collectionView
        }
    }
    open var section: Int = 0
    open var item: Int = 0
    open var size: CGSize = CGSize.zero
    
    open var indexPath: IndexPath {
        get {
            return IndexPath(item: item, section: section)
        }
    }
    
    open func prepareCollectionView() {
        
    }
    
    open func reloadIndexPath() {
    }
    
    open func reloadData() {
        self.collectionView?.reloadItems(at: [self.indexPath])
    }
    
    public final func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public final func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(false, "Must override!!!")
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return size
    }
}
