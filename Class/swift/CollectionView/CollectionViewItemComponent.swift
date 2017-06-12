//
//  CollectionViewItemComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for 1 section and 1 row
open class CollectionViewItemComponent: CollectionViewBaseComponent {
    open var size: CGSize?
    
    public func size(_ size: CGSize) -> Self {
        self.size = size
        return self
    }
    
    open override func firstSection(ofSubComponent: CollectionViewComponent) -> Int {
        return section
    }
    
    open override func firstItem(ofSubComponent: CollectionViewComponent) -> Int {
        return item
    }
    
    open override func reloadData() {
        self.collectionView?.reloadItems(at: [IndexPath(item: item, section: section)])
    }
    
    public final override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public final override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(false, "Must override!!!")
        return UICollectionViewCell()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = size {
            return size
        }
        else {
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
    }
}
