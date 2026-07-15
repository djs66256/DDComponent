//
//  UITablePageViewController.swift
//  DDComponent
//
//  Created by daniel on 2023/9/21.
//

import Foundation

open class UITablePageViewController<P, V>: PageViewController<V, P, V>, UIScrollViewDelegate
where P: UITableViewRootPresenter<V>, V: UITableView {
    
    open var tableViewStyle: UITableView.Style {
        .plain
    }
    
    open override func makeView() -> V {
        V(frame: .zero, style: tableViewStyle)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.scrollDelegate = self
    }
}

public typealias UITablePageDefaultViewController 
= UITablePageViewController<UITableViewRootPresenter<UITableView>, UITableView>
