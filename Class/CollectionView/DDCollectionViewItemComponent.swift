//
//  DDCollectionViewItemComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

// for 1 section and 1 row
public class DDCollectionViewItemComponent: NSObject, DDCollectionViewComponent {
    public weak var collectionView: UICollectionView?
    public var section: Int = 0
    public var item: Int = 0
    
    public var indexPath: NSIndexPath {
        get {
            return NSIndexPath(forItem: item, inSection: section)
        }
    }
    
    public func prepareCollectionView() {
        
    }
    
    public func reloadIndexPath() {
    }
    
    public func reloadData() {
        self.collectionView?.reloadItemsAtIndexPaths([self.indexPath])
    }
    
    public final func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public final func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assert(false, "Must override!!!")
        return UICollectionViewCell()
    }
}
