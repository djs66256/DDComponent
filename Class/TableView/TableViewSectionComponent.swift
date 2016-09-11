//
//  TableViewSectionComponent.swift
//  Component
//
//  Created by daniel on 16/9/11.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open class TableViewSectionComponent: NSObject, TableViewComponent {
    open weak var superComponent: TableViewComponent?
    open var tableView: UITableView? { get { return superComponent?.tableView } }
    open var section: Int = 0
    open var row: Int = 0
    open var headerHeight: CGFloat = 0
    open var footerHeight: CGFloat = 0
    open var height: CGFloat = 0
    open func prepareTableView() {}
    open func reloadIndexPath() {}
    open func updateData() {
        if let tableView = tableView {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: section), with: .none)
            tableView.endUpdates()
        }
    }
    
    public final func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false, "MUST override it!")
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
}

open class TableViewHeaderFooterSectionComponent: TableViewSectionComponent {
    open var headerTitle: String?
    open var footerTitle: String?
    open var headerClass: AnyClass = UITableViewHeaderFooterView.self
    open var footerClass: AnyClass = UITableViewHeaderFooterView.self
    
    open override func prepareTableView() {
        tableView?.register(headerClass, forCellReuseIdentifier: NSStringFromClass(headerClass))
        tableView?.register(footerClass, forCellReuseIdentifier: NSStringFromClass(footerClass))
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(headerClass))
        header?.textLabel?.text = headerTitle
        return header
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(footerClass))
        footer?.textLabel?.text = footerTitle
        return footer
    }
}

open class TableViewItemGroupComponent: TableViewHeaderFooterSectionComponent {
    var subComponents = [TableViewComponent]() {
        didSet {
            for comp in subComponents {
                comp.superComponent = self
            }
        }
    }
    
    override open func reloadIndexPath() {
        if let tableView = tableView {
            super.reloadIndexPath()
            var row = self.row
            for comp in subComponents {
                comp.section = self.section
                comp.row = row
                
                row += comp.tableView(tableView, numberOfRowsInSection: self.section)
                comp.reloadIndexPath()
            }
        }
    }
    
    override open func prepareTableView() {
        for comp in subComponents {
            comp.prepareTableView()
        }
    }
    
    private func component(atRow: Int) -> TableViewComponent? {
        var preComp: TableViewComponent?
        for comp in subComponents {
            if let preComp = preComp {
                if preComp.row <= atRow && comp.row > atRow {
                    return preComp
                }
            }
            preComp = comp
        }
        return preComp
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subComponents.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comp = component(atRow: indexPath.row) {
            return comp.tableView(tableView, cellForRowAt: indexPath)
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: UITableView Delegate
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willDisplay:forRowAt:))) {
                comp.tableView!(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didEndDisplaying:forRowAt:))) {
                comp.tableView!(tableView, didEndDisplaying: cell, forRowAt: indexPath)
            }
        }
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:heightForRowAt:))) {
                return comp.tableView!(tableView, heightForRowAt: indexPath)
            }
            else {
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(tableView(_:accessoryButtonTappedForRowWith:))) {
                comp.tableView!(tableView, accessoryButtonTappedForRowWith: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:shouldShowMenuForRowAt:))) {
                return comp.tableView!(tableView, shouldHighlightRowAt: indexPath)
            }
        }
        return true
    }
    
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didHighlightRowAt:))) {
                comp.tableView!(tableView, didHighlightRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didUnhighlightRowAt:))) {
                comp.tableView!(tableView, didUnhighlightRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willSelectRowAt:))) {
                return comp.tableView!(tableView, willSelectRowAt: indexPath)
            }
        }
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willDeselectRowAt:))) {
                return comp.tableView!(tableView, willDeselectRowAt: indexPath)
            }
        }
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didSelectRowAt:))) {
                comp.tableView!(tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didDeselectRowAt:))) {
                comp.tableView!(tableView, didDeselectRowAt: indexPath)
            }
        }
    }
}
