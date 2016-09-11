//
//  DDTableViewController.swift
//  Component
//
//  Created by daniel on 16/9/12.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

class DDTableViewController: UITableViewController {

    var subComponents: TableViewRootComponent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subComponents = TableViewRootComponent(tableView: self.tableView!)
        self.tableView.dataSource = subComponents
        self.tableView.delegate = subComponents
        
        subComponents?.subComponents = [DDTestTableViewComponent(), DDTestTableViewComponent()]
    }
}
