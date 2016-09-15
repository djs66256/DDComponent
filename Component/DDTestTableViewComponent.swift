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
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = "(\(section), \(row))"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(section(index: 0) == indexPath.section && row(index: 0) == indexPath.row
            && section == indexPath.section && row == indexPath.row) {
            UIAlertView(title: nil, message: "(\(section), \(row))", delegate: nil, cancelButtonTitle: "cancel").show()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
