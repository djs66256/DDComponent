//
//  CollectionPresentable.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation

/// Item presenter type, used by view of collection type.
public protocol CollectionItemPresentable: ViewPresentable {
    
    /// Ruesable view class, will create and reuse when update data.
    /// `UITableViewCell`, `UICollectionViewCell`, `UICollectionReusableView`, etc.
    var itemClass: UIView.Type { get }
    
}


/// Section presenter type, used by view of collection type.
public protocol CollectionSectionPresentable: ViewPresentable {
    
    /// Items in this section
    var items: [CollectionItemPresentable] { get }
    
    /// Supplementaries in this section
    var supplementaries: [String: [CollectionItemPresentable]] { get }
}

/// Root presenter type, used by view of collection type.
public protocol CollectionPresentable: ViewPresentable {
    
    /// Sections in this collection view.
    var sections: [CollectionSectionPresentable] { get }
}

/// Root presenter type, used by view controller of collection type.
public protocol CollectionRootPresentable: CollectionPresentable, RootViewPresentable {
    
}
