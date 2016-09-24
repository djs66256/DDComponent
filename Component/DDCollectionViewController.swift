//
//  CollectionViewController.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let comp = CollectionViewItemGroupComponent()
        comp.subComponents = [TestCollectionViewItemComponent(), TestCollectionViewItemComponent()]
        
        let sectionGroup = CollectionViewSectionGroupComponent()
        let itemGroup2 = CollectionViewItemGroupComponent()
        itemGroup2.subComponents = [TestCollectionViewItemComponent(), TestCollectionViewItemComponent()]
        sectionGroup.subComponents = [TestCollectionViewItemComponent(), itemGroup2]
        self.dd_subComponents = [TestCollectionViewItemComponent(), comp, sectionGroup]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
