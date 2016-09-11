//
//  TableViewItemComponent.swift
//  Component
//
//  Created by daniel on 16/9/11.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open class TableViewItemComponent: NSObject, TableViewComponent {
    open weak var superComponent: TableViewComponent?
    open var tableView: UITableView? {
        get { return superComponent?.tableView }
    }
    open var height: CGFloat = 44
    open var section: Int = 0
    open var row: Int = 0
    open func prepareTableView() {}
    open func reloadIndexPath() {}
    open func updateData() {
        if let tableView = tableView {
            tableView.beginUpdates()
            tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
            tableView.endUpdates()
        }
    }
    
    public final func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false, "MUST override it!")
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }
}
