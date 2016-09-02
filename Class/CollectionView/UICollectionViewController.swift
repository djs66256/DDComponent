//
//  UICollectionViewController.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

var DDCollectionViewRootComponentKey: Int8 = 0


extension UICollectionViewController {
    var dd_rootComponent: DDCollectionViewRootComponent {
        get {
            if let comp = objc_getAssociatedObject(self, &DDCollectionViewRootComponentKey) {
                return comp as! DDCollectionViewRootComponent
            }
            else {
                let comp = DDCollectionViewRootComponent(collectionView: self.collectionView)
                objc_setAssociatedObject(self, &DDCollectionViewRootComponentKey, comp, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return comp
            }
        }
    }
    
    var dd_subComponents: [DDCollectionViewComponent] {
        set {
            dd_rootComponent.subComponents = newValue
        }
        get {
            return dd_rootComponent.subComponents
        }
    }
    
}
