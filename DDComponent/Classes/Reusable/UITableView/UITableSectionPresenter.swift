//
//  UITableSectionPresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/9/22.
//

import Foundation

public protocol UITableViewSectionPresentable: CollectionSectionPresentable {
    var headerTitle: String? { get set }
    var footerTitle: String? { get set }
    var indexTitle: String? { get set }
}

open class UITableViewSectionPresenter: CollectionSectionPresenter {
    public var titleForHeader: String? = nil
    public var titleForFooter: String? = nil
    public var indexTitle: String? = nil
}


public extension UITableViewSectionPresenter {
    
    var header: UITableViewItemPresentable? {
        get {
            supplementaries[CollectionElementKind.sectionHeader]?.first as? UITableViewItemPresentable
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionHeader, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionHeader)
            }
        }
    }
    
    var footer: UITableViewItemPresentable? {
        get {
            supplementaries[CollectionElementKind.sectionFooter]?.first as? UITableViewItemPresentable
        }
        set {
            if let newValue = newValue {
                setSupplementary(CollectionElementKind.sectionFooter, [newValue])
            }
            else {
                removeSupplementary(CollectionElementKind.sectionFooter)
            }
        }
    }
}
