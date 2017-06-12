//
//  UITableViewController.swift
//  Component
//
//  Created by daniel on 16/9/25.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

private var TableViewRootComponentKey: Int8 = 0

public extension UITableViewController {

    public var dd_rootComponent: TableViewRootComponent {
        get {
            if let comp = objc_getAssociatedObject(self, &TableViewRootComponentKey) {
                return comp as! TableViewRootComponent
            }
            else {
                let comp = TableViewRootComponent(tableView: self.tableView)
                objc_setAssociatedObject(self, &TableViewRootComponentKey, comp, .OBJC_ASSOCIATION_RETAIN)
                return comp
            }
        }
    }
    
    public var dd_subComponents: [TableViewBaseComponent] {
        set {
            dd_rootComponent.subComponents = newValue
        }
        get {
            return dd_rootComponent.subComponents
        }
    }

}
