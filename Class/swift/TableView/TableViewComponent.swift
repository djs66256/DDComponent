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
    func prepareTableView()
//    func reloadIndexPath()
    func reloadData()
    
    // for subComponent
    func firstRow(ofSubComponent: TableViewComponent) -> Int
    func firstSection(ofSubComponent: TableViewComponent) -> Int
}

open class TableViewBaseComponent: NSObject, TableViewComponent {
    open weak var superComponent: TableViewComponent?
    open func prepareTableView() {}
    open func reloadData() {}
    
    open func firstRow(ofSubComponent: TableViewComponent) -> Int {
        return 0
    }
    open func firstSection(ofSubComponent: TableViewComponent) -> Int {
        return 0
    }
    
    open var tableView: UITableView? {
        get { return superComponent?.tableView }
    }
    
    open var row: Int {
        get {
            return superComponent?.firstRow(ofSubComponent: self) ?? 0
        }
    }
    
    open var section: Int {
        get {
            return superComponent?.firstSection(ofSubComponent: self) ?? 0
        }
    }
    
    // MARK: DataSource
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false)
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
    // MARK: Delegate
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { }
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) { }
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) { }
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) { }
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
//    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 0
//    }
//    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
//    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) { }
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) { }
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { }
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}
