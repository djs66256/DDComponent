//
//  TableViewSectionGroupComponent.swift
//  Component
//
//  Created by daniel on 16/9/11.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open class TableViewSectionGroupComponent: NSObject, TableViewComponent {
    open var subComponents = [TableViewComponent]() {
        didSet {
            for comp in subComponents {
                comp.superComponent = self
            }
        }
    }
    open weak var superComponent: TableViewComponent?
    open var tableView: UITableView? {
        get { return superComponent?.tableView }
    }
    open var section: Int = 0
    open var row: Int = 0
    open func prepareTableView() {
        for comp in subComponents {
            comp.prepareTableView()
        }
    }
    open func reloadIndexPath() {
        if let tableView = tableView {
            for comp in subComponents {
                comp.section = section
                comp.row = 0
                section += comp.numberOfSections!(in: tableView)
                comp.reloadIndexPath()
            }
        }
    }
    open func updateData() {
        if let tableView = tableView {
            tableView.beginUpdates()
            let maxSection = section + numberOfSections(in: tableView)
            tableView.reloadSections(IndexSet(integersIn: section...maxSection), with: .none)
            tableView.endUpdates()
        }
    }
    
    private func component(atSection: Int) -> TableViewComponent? {
        var preComp: TableViewComponent?
        for comp in subComponents {
            if let preComp = preComp {
                if preComp.section <= atSection && comp.section > atSection {
                    return preComp
                }
            }
            preComp = comp
        }
        return preComp
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        var section = 0
        for comp in subComponents {
            section += comp.numberOfSections!(in: tableView)
        }
        return section
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section2: Int) -> Int {
        if let comp = component(atSection: section2) {
            return comp.tableView(tableView, numberOfRowsInSection: section2)
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comp = component(atSection: indexPath.section) {
            return comp.tableView(tableView, cellForRowAt: indexPath)
        }
        return UITableViewCell()
    }
    
    // MARK: UITableView Delegate
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willDisplayHeaderView:forSection:))) {
                comp.tableView!(tableView, willDisplayHeaderView: view, forSection: section)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willDisplayFooterView:forSection:))) {
                comp.tableView!(tableView, willDisplayFooterView: view, forSection: section)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didEndDisplayingHeaderView:forSection:))) {
                comp.tableView!(tableView, didEndDisplayingHeaderView: view, forSection: section)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didEndDisplayingFooterView:forSection:))) {
                comp.tableView!(tableView, didEndDisplayingFooterView: view, forSection: section)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(tableView(_:heightForHeaderInSection:))) {
                return comp.tableView!(tableView, heightForHeaderInSection: section)
            }
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(tableView(_:heightForFooterInSection:))) {
                return comp.tableView!(tableView, heightForFooterInSection: section)
            }
        }
        return 0
    }
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(tableView(_:viewForHeaderInSection:))) {
                return comp.tableView!(tableView, viewForHeaderInSection: section)
            }
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let comp = component(atSection: section) {
            if comp.responds(to: #selector(tableView(_:viewForFooterInSection:))) {
                return comp.tableView!(tableView, viewForFooterInSection: section)
            }
        }
        return nil
    }
    
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willDisplay:forRowAt:))) {
                comp.tableView!(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didEndDisplaying:forRowAt:))) {
                comp.tableView!(tableView, didEndDisplaying: cell, forRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:heightForRowAt:))) {
                return comp.tableView!(tableView, heightForRowAt: indexPath)
            }
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:accessoryButtonTappedForRowWith:))) {
                comp.tableView!(tableView, accessoryButtonTappedForRowWith: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:shouldShowMenuForRowAt:))) {
                return comp.tableView!(tableView, shouldHighlightRowAt: indexPath)
            }
        }
        return true
    }
    
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didHighlightRowAt:))) {
                comp.tableView!(tableView, didHighlightRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didUnhighlightRowAt:))) {
                comp.tableView!(tableView, didUnhighlightRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willSelectRowAt:))) {
                return comp.tableView!(tableView, willSelectRowAt: indexPath)
            }
        }
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:willDeselectRowAt:))) {
                return comp.tableView!(tableView, willDeselectRowAt: indexPath)
            }
        }
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didSelectRowAt:))) {
                comp.tableView!(tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            if comp.responds(to: #selector(TableViewComponent.tableView(_:didDeselectRowAt:))) {
                comp.tableView!(tableView, didDeselectRowAt: indexPath)
            }
        }
    }
}

open class TableViewRootComponent: TableViewSectionGroupComponent {
    private var tableViewInstance: UITableView
    open override var tableView: UITableView? {
        get { return tableViewInstance }
    }
    
    override open var subComponents: [TableViewComponent] {
        didSet {
            reloadIndexPath()
            prepareTableView()
        }
    }
    
    public init(tableView: UITableView, bind: Bool = true) {
        tableViewInstance = tableView
        super.init()
        if bind {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    open override func updateData() {
        reloadIndexPath()
        tableView?.reloadData()
    }
    
    open func reloadData() {
        reloadIndexPath()
        prepareTableView()
        tableView?.reloadData()
    }
}
