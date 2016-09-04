//
//  UICollectionViewController.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

private var CollectionViewRootComponentKey: Int8 = 0

public extension UICollectionViewController {
    public var dd_rootComponent: CollectionViewRootComponent {
        get {
            if let comp = objc_getAssociatedObject(self, &CollectionViewRootComponentKey) {
                return comp as! CollectionViewRootComponent
            }
            else {
                let comp = CollectionViewRootComponent(collectionView: self.collectionView)
                objc_setAssociatedObject(self, &CollectionViewRootComponentKey, comp, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return comp
            }
        }
    }
    
    public var dd_subComponents: [CollectionViewComponent] {
        set {
            dd_rootComponent.subComponents = newValue
        }
        get {
            return dd_rootComponent.subComponents
        }
    }
    
}
