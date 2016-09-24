//
//  TableViewSectionGroupComponent.swift
//  Component
//
//  Created by daniel on 16/9/11.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open class TableViewSectionGroupComponent: TableViewBaseComponent {
    open var subComponents = [TableViewBaseComponent]() {
        didSet {
            let shouldPrepare = self.tableView != nil
            for comp in subComponents {
                comp.superComponent = self
                if shouldPrepare {
                    comp.prepareTableView()
                }
            }
        }
    }
    
    open func index(section: Int) -> Int {
        return section - self.section
    }
    open func section(index: Int) -> Int {
        return index + self.section
    }
    
    open override func prepareTableView() {
        if tableView != nil {
            for comp in subComponents {
                comp.prepareTableView()
            }
        }
    }
    
    open override func firstSection(ofSubComponent: TableViewComponent) -> Int {
        var section = self.section
        if let tableView = tableView {
            for comp in subComponents {
                if comp === ofSubComponent {
                    return section
                }
                else {
                    section += comp.numberOfSections(in: tableView)
                }
            }
        }
        return section
    }
    
    open override func reloadData() {
        if let tableView = tableView {
            tableView.beginUpdates()
            let maxSection = section + numberOfSections(in: tableView)
            tableView.reloadSections(IndexSet(integersIn: section..<maxSection), with: .none)
            tableView.endUpdates()
        }
    }
    
    private func component(atSection: Int) -> TableViewBaseComponent? {
        if let tableView = tableView {
            var section = self.section
            for comp in subComponents {
                let count = comp.numberOfSections(in: tableView)
                if section <= atSection && section+count > atSection {
                    return comp
                }
                section += count
            }
        }
        return nil
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        var section = 0
        for comp in subComponents {
            section += comp.numberOfSections(in: tableView)
        }
        return section
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section2: Int) -> Int {
        if let comp = component(atSection: section2) {
            return comp.tableView(tableView, numberOfRowsInSection: section2)
        }
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comp = component(atSection: indexPath.section) {
            return comp.tableView(tableView, cellForRowAt: indexPath)
        }
        return UITableViewCell()
    }
    
    // MARK: UITableView Delegate
    open override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            comp.tableView(tableView, willDisplayHeaderView: view, forSection: section)
        }
    }
    
    open override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            comp.tableView(tableView, willDisplayFooterView: view, forSection: section)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            comp.tableView(tableView, didEndDisplayingHeaderView: view, forSection: section)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let comp = component(atSection: section) {
            comp.tableView(tableView, didEndDisplayingFooterView: view, forSection: section)
        }
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let comp = component(atSection: section) {
            return comp.tableView(tableView, heightForHeaderInSection: section)
        }
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let comp = component(atSection: section) {
            return comp.tableView(tableView, heightForFooterInSection: section)
        }
        return 0
    }
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let comp = component(atSection: section) {
            return comp.tableView(tableView, viewForHeaderInSection: section)
        }
        return nil
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let comp = component(atSection: section) {
            return comp.tableView(tableView, viewForFooterInSection: section)
        }
        return nil
    }
    
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.tableView(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let comp = component(atSection: indexPath.section) {
            return comp.tableView(tableView, heightForRowAt: indexPath)
        }
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.tableView(tableView, accessoryButtonTappedForRowWith: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let comp = component(atSection: indexPath.section) {
            return comp.tableView(tableView, shouldHighlightRowAt: indexPath)
        }
        return true
    }
    
    open override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.tableView(tableView, didHighlightRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.tableView(tableView, didUnhighlightRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atSection: indexPath.section) {
            return comp.tableView(tableView, willSelectRowAt: indexPath)
        }
        return indexPath
    }
    
    open override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atSection: indexPath.section) {
            return comp.tableView(tableView, willDeselectRowAt: indexPath)
        }
        return indexPath
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let comp = component(atSection: indexPath.section) {
            comp.tableView(tableView, didDeselectRowAt: indexPath)
        }
    }
}

open class TableViewRootComponent: TableViewSectionGroupComponent {
    private var tableViewInstance: UITableView
    open override var tableView: UITableView? {
        get { return tableViewInstance }
    }
    
    public init(tableView: UITableView, bind: Bool = true) {
        tableViewInstance = tableView
        super.init()
        if bind {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    open override func reloadData() {
        tableView?.reloadData()
    }
}
