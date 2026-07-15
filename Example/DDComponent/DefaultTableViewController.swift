//
//  DefaultTableViewController.swift
//  DDComponent_Example
//
//  Created by daniel on 2023/9/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import DDComponent

class DefaultTableViewController: UITablePageDefaultViewController {
    
    var dataSource = [
        TableCellModel(image: nil, text: "title 1", detail: "detail 1"),
        TableCellModel(image: nil, text: "title 2", detail: "detail 2"),
        TableCellModel(image: nil, text: "title 3", detail: "detail 3"),
        TableCellModel(image: nil, text: "title 4", detail: "detail 4"),
        TableCellModel(image: nil, text: "title 5", detail: "detail 5"),
        TableCellModel(image: nil, text: "title 6", detail: "detail 6"),
        TableCellModel(image: nil, text: "title 7", detail: "detail 7")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.sections = [
            UITableViewSectionPresenter(items: dataSource.map {
                let p = TableViewDefaultCellPresenterHolder()
                p.model = $0
                return p
            })
        ]
    }
}
