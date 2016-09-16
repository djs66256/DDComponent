//
//  TableViewItemComponent.swift
//  Component
//
//  Created by daniel on 16/9/11.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open class TableViewItemComponent: TableViewBaseComponent {
    open var height: CGFloat = 44
    open override func firstSection(ofSubComponent: TableViewComponent) -> Int {
        return section
    }
    open override func firstRow(ofSubComponent: TableViewComponent) -> Int {
        return row
    }
    
    open override func reloadData() {
        if let tableView = tableView {
            tableView.beginUpdates()
            tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
            tableView.endUpdates()
        }
    }
    
    public func height(_ height: CGFloat) -> Self {
        self.height = height
        return self
    }
    
    public override final func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public override final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false, "MUST override it!")
        return UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }
}
