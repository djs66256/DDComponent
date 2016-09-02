//
//  DDTestCollectionViewItemComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

class DDTestCollectionViewItemComponent: DDCollectionViewItemComponent {

    override func prepareCollectionView() {
        self.collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UICollectionViewCell))
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(UICollectionViewCell), forIndexPath: indexPath)
        cell.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1);
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80, height: 80);
    }
}
