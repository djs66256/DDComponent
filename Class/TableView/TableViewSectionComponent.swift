//
//  TableViewSectionComponent.swift
//  Component
//
//  Created by daniel on 16/9/11.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

open class TableViewSectionComponent: TableViewBaseComponent {
    open var headerHeight: CGFloat = 0
    open var footerHeight: CGFloat = 0
    open var height: CGFloat = 0
    
    open override func reloadData() {
        if let tableView = tableView {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer: section), with: .none)
            tableView.endUpdates()
        }
    }
    
    public override final func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false, "MUST override it!")
        return UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
}

public extension TableViewSectionComponent {
    public func headerHeight(_ height: CGFloat) -> Self {
        self.headerHeight = height
        return self
    }
    public func footerHeight(_ height: CGFloat) -> Self {
        self.footerHeight = height
        return self
    }
    public func height(_ height: CGFloat) -> Self {
        self.height = height
        return self
    }
}

open class TableViewHeaderFooterTitleComponent: TableViewSectionComponent {
    open var headerTitle: String?
    open var footerTitle: String?
    open var headerClass: AnyClass = UITableViewHeaderFooterView.self
    open var footerClass: AnyClass = UITableViewHeaderFooterView.self
    
    public func headerTitle(_ title: String) -> Self {
        self.headerTitle = title
        return self
    }
    public func footerTitle(_ title: String) -> Self {
        self.footerTitle = title
        return self
    }
    public func headerClass(_ cls: AnyClass) -> Self {
        self.headerClass = cls
        return self
    }
    public func footerClass(_ cls: AnyClass) -> Self {
        self.footerClass = cls
        return self
    }
    
    open override func prepareTableView() {
        tableView?.register(headerClass, forHeaderFooterViewReuseIdentifier: NSStringFromClass(headerClass))
        tableView?.register(footerClass, forHeaderFooterViewReuseIdentifier: NSStringFromClass(footerClass))
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false)
        return UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(headerClass))
        header?.textLabel?.text = headerTitle
        return header
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(footerClass))
        footer?.textLabel?.text = footerTitle
        return footer
    }
}

open class TableViewHeaderFooterSectionComponent: TableViewSectionComponent {
    open var headerComponent: TableViewSectionComponent? {
        didSet {
            headerComponent?.superComponent = self
        }
    }
    open var footerComponent: TableViewSectionComponent? {
        didSet {
            footerComponent?.superComponent = self
        }
    }
    open var headerFooterComponent: TableViewSectionComponent? {
        didSet {
            headerFooterComponent?.superComponent = self
        }
    }
    
    open override var headerHeight: CGFloat {
        set { super.headerHeight = newValue }
        get {
            if let header = (headerComponent ?? headerFooterComponent) {
                return header.headerHeight
            }
            return super.headerHeight
        }
    }
    
    open override var footerHeight: CGFloat {
        set { super.footerHeight = newValue }
        get {
            if let footer = (footerComponent ?? headerFooterComponent) {
                return footer.footerHeight
            }
            return super.footerHeight
        }
    }
    
    open override func prepareTableView() {
        super.prepareTableView()
        headerComponent?.prepareTableView()
        footerComponent?.prepareTableView()
        headerFooterComponent?.prepareTableView()
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = (headerComponent ?? headerFooterComponent) {
            return header.tableView(tableView, viewForHeaderInSection: section)
        }
        else {
            return super.tableView(tableView, viewForHeaderInSection: section)
        }
    }
    
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = (footerComponent ?? headerFooterComponent) {
            return footer.tableView(tableView, viewForFooterInSection: section)
        }
        else {
            return super.tableView(tableView, viewForFooterInSection: section)
        }
    }
    
    public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = (headerComponent ?? headerFooterComponent) {
            header.tableView(tableView, willDisplayHeaderView: view, forSection: section)
        }
        else {
            super.tableView(tableView, willDisplayHeaderView: view, forSection: section)
        }
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let header = (headerComponent ?? headerFooterComponent) {
            header.tableView(tableView, didEndDisplayingHeaderView: view, forSection: section)
        }
        else {
            super.tableView(tableView, didEndDisplayingHeaderView: view, forSection: section)
        }
    }
    
    public override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = (footerComponent ?? headerFooterComponent) {
            footer.tableView(tableView, willDisplayFooterView: view, forSection: section)
        }
        else {
            super.tableView(tableView, willDisplayFooterView: view, forSection: section)
        }
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let footer = (footerComponent ?? headerFooterComponent) {
            footer.tableView(tableView, didEndDisplayingFooterView: view, forSection: section)
        }
        else {
            super.tableView(tableView, didEndDisplayingFooterView: view, forSection: section)
        }
    }
}

open class TableViewItemGroupComponent: TableViewHeaderFooterSectionComponent {
    var subComponents = [TableViewBaseComponent]() {
        didSet {
            for comp in subComponents {
                comp.superComponent = self
            }
            prepareTableView()
        }
    }
    
    open func index(row: Int) -> Int {
        return row - self.row
    }
    open func row(index: Int) -> Int {
        return index + self.row
    }
    
    open override func firstSection(ofSubComponent: TableViewComponent) -> Int {
        return section
    }
    override open func firstRow(ofSubComponent: TableViewComponent) -> Int {
        var row = self.row
        if let tableView = tableView {
            let section = self.section
            for comp in subComponents {
                if comp === ofSubComponent {
                    return row
                }
                else {
                    row += comp.tableView(tableView, numberOfRowsInSection:section)
                }
            }
        }
        return row
    }
    
    override open func prepareTableView() {
        super.prepareTableView()
        if tableView != nil {
            for comp in subComponents {
                comp.prepareTableView()
            }
        }
    }
    
    private func component(atRow: Int) -> TableViewBaseComponent? {
        if let tableView = tableView {
            var row = self.row
            let section = self.section
            for comp in subComponents {
                let count = comp.tableView(tableView, numberOfRowsInSection: section)
                if row <= atRow && row+count > atRow {
                    return comp
                }
                row += count
            }
        }
        return nil
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        for comp in subComponents {
            count += comp.tableView(tableView, numberOfRowsInSection: section)
        }
        return count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let comp = component(atRow: indexPath.row) {
            return comp.tableView(tableView, cellForRowAt: indexPath)
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: UITableView Delegate
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            comp.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            comp.tableView(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let comp = component(atRow: indexPath.row) {
            let height = comp.tableView(tableView, heightForRowAt: indexPath)
            if !height.isZero {
                return height
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    open override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            comp.tableView(tableView, accessoryButtonTappedForRowWith: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let comp = component(atRow: indexPath.row) {
            return comp.tableView(tableView, shouldHighlightRowAt: indexPath)
        }
        return true
    }
    
    open override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            comp.tableView(tableView, didHighlightRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            comp.tableView(tableView, didUnhighlightRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atRow: indexPath.row) {
            return comp.tableView(tableView, willSelectRowAt: indexPath)
        }
        return indexPath
    }
    
    open override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let comp = component(atRow: indexPath.row) {
            return comp.tableView(tableView, willDeselectRowAt: indexPath)
        }
        return indexPath
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            comp.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let comp = component(atRow: indexPath.row) {
            comp.tableView(tableView, didDeselectRowAt: indexPath)
        }
    }
}
