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
        
        let itemGroup = TableViewItemGroupComponent()
        itemGroup.headerHeight = 10
        itemGroup.footerHeight = 10
        itemGroup.subComponents = [DDTestTableViewComponent(), DDTestTableViewComponent()]
        
        let itemGroup0 = TableViewItemGroupComponent()
        itemGroup0.headerHeight = 10
        itemGroup0.footerHeight = 10
        itemGroup0.subComponents = [DDTestTableViewComponent(), DDTestTableViewComponent()]
        let itemGroup1 = TableViewItemGroupComponent()
        itemGroup1.subComponents = [DDTestTableViewComponent(), itemGroup0, DDTestTableViewComponent()]

        
        let headerFooter = TableViewHeaderFooterTitleComponent()
        headerFooter.headerTitle = "header"
        headerFooter.footerTitle = "footer"
        headerFooter.headerHeight = 30
        headerFooter.footerHeight = 30
        let itemGroup2 = TableViewItemGroupComponent()
        itemGroup2.headerFooterComponent = headerFooter
        itemGroup2.headerHeight = 10
        itemGroup2.footerHeight = 10
        itemGroup2.subComponents = [DDTestTableViewComponent(), DDTestTableViewComponent()]
        let sectionGroup = TableViewSectionGroupComponent()
        sectionGroup.subComponents = [DDTestTableViewComponent(), itemGroup2, DDTestTableViewComponent()]
        
        subComponents?.subComponents = [DDTestTableViewComponent(), itemGroup, itemGroup1, sectionGroup, DDTestTableViewComponent()]
    }
}
