//
//  DDTestTableViewComponent.swift
//  Component
//
//  Created by daniel on 16/9/12.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

class DDTestTableViewComponent: TableViewItemComponent {

    override func prepareTableView() {
        super.prepareTableView()
        self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
