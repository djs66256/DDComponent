//
//  TableViewComponent.swift
//  Component
//
//  Created by daniel on 16/9/11.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public protocol TableViewComponent : UITableViewDataSource, UITableViewDelegate {
    weak var superComponent: TableViewComponent? { get set }
    var tableView: UITableView? { get }
    var section: Int { get set }
    var row: Int { get set }
    func prepareTableView()
    func reloadIndexPath()
    func updateData()
    
}

public extension TableViewComponent {
    
    func row(rawRow: Int) -> Int {
        return rawRow - self.row
    }
    func rawRow(row: Int) -> Int {
        return row + self.row
    }
    
    func section(rawSection: Int) -> Int {
        return rawSection - self.section
    }
    func rawSection(section: Int) -> Int {
        return section + self.section
    }
}
