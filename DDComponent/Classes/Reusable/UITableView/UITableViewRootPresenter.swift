//
//  UITableViewPresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/9/21.
//

import Foundation
import UIKit

public protocol UITableViewRootPresentable: UITableViewPresentable, CollectionRootPresentable {
}

open class UITableViewRootPresenter<V: UITableView>: RootViewPresenter<V>, UITableViewRootPresentable {
    
    public private(set) lazy var tablePresenter = UITableViewPresenter<V>()
    
    public required init() {
        super.init()
        add(child: tablePresenter)
    }
    
    public var proxy: UITableViewDelegateProxy? {
        tablePresenter.proxy
    }
    
    public var displayIndexTitles: Bool {
        get { tablePresenter.displayIndexTitles }
        set { tablePresenter.displayIndexTitles = newValue }
    }
    
    public var sections: [CollectionSectionPresentable] {
        get { tablePresenter.sections }
        set { tablePresenter.sections = newValue }
    }
    
    public var scrollDelegate: UIScrollViewDelegate? {
        get { tablePresenter.scrollDelegate }
        set { tablePresenter.scrollDelegate = newValue }
    }
    
    public override var viewUpdatePipeline: ViewUpdatePipeline? {
        tablePresenter.viewUpdatePipeline
    }
    
    open override func bindView(_ view: V) {
        super.bindView(view)
        tablePresenter.bindView(view)
    }
    
    open override func bindWeakView(_ view: V) {
        super.bindWeakView(view)
        tablePresenter.bindWeakView(view)
    }
    
    public override func unbindView() {
        super.unbindView()
        tablePresenter.unbindView()
    }
    
    open func didEndMultipleSelectionInteraction() {
        tablePresenter.didEndMultipleSelectionInteraction()
    }
}
