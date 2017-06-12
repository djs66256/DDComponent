//
//  TableViewStatusComponent.swift
//  Component
//
//  Created by daniel on 16/9/24.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open
class TableViewStatusComponent: TableViewBaseComponent {
    public typealias ComponentState = String
    private var stateStore = [ComponentState: TableViewBaseComponent]()
    
    public var state: ComponentState? {
        didSet {
            if oldValue != state {
                self.reloadData()
            }
        }
    }
    
    open override func reloadData() {
        self.tableView?.reloadData()
    }
    
    public func set(_ component: TableViewBaseComponent, for state: ComponentState) {
        stateStore[state] = component
    }
    
    public func component(for state: ComponentState) -> TableViewBaseComponent? {
        return stateStore[state]
    }
    
    // MARK: override
    private func currentComponent() -> TableViewBaseComponent? {
        if let state = state {
            return component(for: state)
        }
        return nil
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        if let comp = currentComponent() {
            return comp.numberOfSections(in: tableView)
        }
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comp = currentComponent() {
            return comp.tableView(tableView, numberOfRowsInSection: section)
        }
        return 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comp = currentComponent() {
            return comp.tableView(tableView, cellForRowAt: indexPath)
        }
        return UITableViewCell()
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let comp = currentComponent() {
            return comp.tableView(tableView, titleForFooterInSection: section)
        }
        return nil
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let comp = currentComponent() {
            return comp.tableView(tableView, titleForHeaderInSection: section)
        }
        return nil
    }
    
    
    // MARK: Delegate
    public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let comp = currentComponent() {
            comp.tableView(tableView, willDisplayHeaderView: view, forSection: section)
        }
    }
    public override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let comp = currentComponent() {
            comp.tableView(tableView, didEndDisplayingHeaderView: view, forSection: section)
        }
    }
    public override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let comp = currentComponent() {
            comp.tableView(tableView, willDisplayFooterView: view, forSection: section)
        }
    }
    public override func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let comp = currentComponent() {
            comp.tableView(tableView, didEndDisplayingFooterView: view, forSection: section)
        }
    }
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.tableView(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let comp = currentComponent() {
            return comp.tableView(tableView, heightForHeaderInSection: section)
        }
        return 0
    }
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let comp = currentComponent() {
            return comp.tableView(tableView, heightForFooterInSection: section)
        }
        return 0
    }
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let comp = currentComponent() {
            return comp.tableView(tableView, heightForRowAt: indexPath)
        }
        return 0
    }
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let comp = currentComponent() {
            return comp.tableView(tableView, viewForHeaderInSection: section)
        }
        return nil
    }
    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let comp = currentComponent() {
            return comp.tableView(tableView, viewForFooterInSection: section)
        }
        return nil
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    public override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = currentComponent() {
            return comp.tableView(tableView, willSelectRowAt: indexPath)
        }
        return indexPath
    }
    public override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let comp = currentComponent() {
            return comp.tableView(tableView, shouldHighlightRowAt: indexPath)
        }
        return true
    }
    public override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.tableView(tableView, didHighlightRowAt: indexPath)
        }
    }
    public override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.tableView(tableView, didUnhighlightRowAt: indexPath)
        }
    }
    public override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = currentComponent() {
            return comp.tableView(tableView, willDeselectRowAt: indexPath)
        }
        return indexPath
    }
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.tableView(tableView, didDeselectRowAt: indexPath)
        }
    }
    
    public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let comp = currentComponent() {
            comp.tableView(tableView, accessoryButtonTappedForRowWith: indexPath)
        }
    }
    public override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let comp = currentComponent() {
            return comp.tableView(tableView, editActionsForRowAt: indexPath)
        }
        return nil
    }
}
