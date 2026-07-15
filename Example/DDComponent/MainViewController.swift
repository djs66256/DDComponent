//
//  ViewController.swift
//  DDComponent
//
//  Created by daniel on 08/30/2022.
//  Copyright (c) 2022 daniel. All rights reserved.
//

import UIKit

@objc(BMMainViewController)
class MainViewController: UITableViewController {
    
    struct DataSource {
        let name: String
        let vc: () -> UIViewController
        let action: (()->Void)?
    }
    
    let dataSource: [DataSource] = [
        .init(name: "Persenter 1 Example", vc: { Page1ViewController() }, action: nil),
        .init(name: "CyclePageView Example", vc: {TestCyclePageViewController()}, action: nil),
        .init(name: "CyclePageView with Presenter Example", vc: {TestPresenterCyclePageViewController()}, action: nil),
        .init(name: "Collection Static View", vc: { CollectionStaticViewController() }, action: nil),
//        .init(name: "EffectsSelectionViewController", vc: { EffectsSelectionViewController() }, action: nil),
        .init(name: "DefaultTableViewController", vc: { DefaultTableViewController() }, action: nil)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        self.title = "Main View Controller"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataSource[indexPath.row]
        if let action = data.action {
            action()
        }
        else {
            let vc = data.vc()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
