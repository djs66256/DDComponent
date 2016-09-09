//
//  CollectionViewComponent.swift
//  Component
//
//  Created by daniel on 16/8/21.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public protocol CollectionViewComponent: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var superComponent: CollectionViewComponent? { get set }
    var collectionView: UICollectionView? { get }
    var section: Int { get set }
    var item: Int { get set }
    func prepareCollectionView()
    func reloadIndexPath()
    func reloadData()
}

public extension CollectionViewComponent {
    
    func item(rawItem: Int) -> Int {
        return rawItem - self.item
    }
    func rawItem(item: Int) -> Int {
        return item + self.item
    }
    
    func section(rawSection: Int) -> Int {
        return rawSection - self.section
    }
    func rawSection(section: Int) -> Int {
        return section + self.section
    }
}

