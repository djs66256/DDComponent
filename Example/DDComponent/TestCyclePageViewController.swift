//
//  PageViewController.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import DDComponent
import SnapKit

@MainActor
class TestCyclePageViewController: UIViewController, CyclePageDelegate, CyclePageDataSource {

    let pageView = CyclePageView(UIScrollView())//PageScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        pageView.delegate = self
        pageView.dataSource = self
        view.addSubview(pageView)
        pageView.frame = view.bounds
        pageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        pageView.currentItem = dataSource[0]
    }
    
    lazy var dataSource: [PageVM] = (0...10).map {
        PageVM(index: $0)
    }
    
    func prev(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
        if let vm = current as? PageVM {
            let index = vm.index - 1
            if index >= 0 {
                return dataSource[index]
            }
        }
        return nil
    }
    func next(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
        if let vm = current as? PageVM {
            let index = vm.index + 1
            if index < dataSource.count {
                return dataSource[index]
            }
        }
        return nil
    }
    
    func goPrev(_ page: CyclePageView, item: CyclePageItemable) -> Bool {
        true
    }
    func goNext(_ page: CyclePageView, item: CyclePageItemable) -> Bool {
        true
    }
    func goCurrent(_ page: CyclePageView, item: CyclePageItemable) {
        
    }
    func skipItem(_ page: CyclePageView, item: CyclePageItemable) {
        
    }
    func itemsChanged(_ page: CyclePageView,
                    oldItems: [CyclePageItemable],
                      newItems: [CyclePageItemable]) {
        
    }
    func currentWillChanged(_ page: CyclePageView,
                           oldItem: CyclePageItemable?,
                            newItem: CyclePageItemable?) {
        
    }
    func currentChanged(_ page: CyclePageView) {
        
    }
    func currentRefresh(_ page: CyclePageView) {
        
    }
    func itemViewDidLayout(_ page: CyclePageView,
                           itemView: CyclePageItemView) {
        
    }
}
