//
//  DDCollectionViewItemComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

class DDCollectionViewItemComponent: NSObject, DDCollectionViewComponent {
    weak var collectionView: UICollectionView?
    var section: Int = 0
    var item: Int = 0
    
    var indexPath: NSIndexPath {
        get {
            return NSIndexPath(forItem: item, inSection: section)
        }
    }
    
    func prepareCollectionView() {
        
    }
    
    func reloadIndexPath() {
    }
    
    func reloadData() {
        self.collectionView?.reloadItemsAtIndexPaths([self.indexPath])
    }
    
    final func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    final func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assert(false, "Must override!!!")
        return UICollectionViewCell()
    }
}
