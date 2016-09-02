//
//  DDCollectionViewController.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class DDCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let comp = DDCollectionViewItemGroupComponent()
        comp.subComponents = [DDTestCollectionViewItemComponent(), DDTestCollectionViewItemComponent()]
        self.dd_subComponents = [comp]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
