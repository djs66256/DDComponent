//
//  DDCollectionViewComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public protocol DDCollectionViewComponent: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var collectionView: UICollectionView? { get set }
    var section: Int { get set }
    var item: Int { get set }
    func prepareCollectionView()
    func reloadIndexPath()
    func reloadData()
}

public extension DDCollectionViewComponent {
    
    func itemWithRawItem(rawItem: Int) -> Int {
        return rawItem - self.item
    }
    func rawItemWithItem(item: Int) -> Int {
        return item + self.item
    }
    
    func sectionWithRawSection(rawSection: Int) -> Int {
        return rawSection - self.section
    }
    func rawSectionWithSection(section: Int) -> Int {
        return section + self.section
    }
}

