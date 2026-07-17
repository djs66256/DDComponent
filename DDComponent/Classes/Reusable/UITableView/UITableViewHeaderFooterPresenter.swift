//
//  UITableViewHeaderFooterPresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/10/7.
//

import Foundation
import UIKit

open class UITableViewHeaderFooterPresenter<V: UIView>: CollectionItemPresenter<V>, UITableViewItemPresentable, UITableViewItemSizeCalculatable {
    public var layoutInfo = UITableViewCellLayoutInfo()
    open func calculateHeight(containerSize: CGSize) -> CGFloat { 0 }
    
    // Methods below are useless, just to make header footer using the same type of `UITableViewItemPresentable`.
    // Display
    @available(*, deprecated)
    public func onWillDisplay() {}
    @available(*, deprecated)
    public func onDidEndDisplaying() {}
    
    // Highlight & select
    @available(*, deprecated)
    public var shouldHighlight: Bool = false
    @available(*, deprecated)
    public func onDidHighlight() {}
    @available(*, deprecated)
    public func onDidUnhighlight() {}
    @available(*, deprecated)
    public func onWillSelect() {}
    @available(*, deprecated)
    public func onWillDeselect() {}
    @available(*, deprecated)
    public func onDidSelect() {}
    @available(*, deprecated)
    public func onDidDeselect() {}
    
    // Edit
    @available(*, deprecated)
    public var canEdit: Bool = false
    @available(*, deprecated)
    public var editStyle: UITableViewCell.EditingStyle = .none
    @available(*, deprecated)
    public var deleteConfirmationButtonTitle: String? = nil
    @available(*, deprecated)
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    public var editActions: [UITableViewRowAction]? = nil
    @available(*, deprecated)
    public var leadingSwipeActionsConfiguration: UISwipeActionsConfiguration? = nil
    @available(*, deprecated)
    public var trailingSwipeActionsConfiguration: UISwipeActionsConfiguration? = nil
    @available(*, deprecated)
    public var shouldIndentWhileEditing: Bool = false
    @available(*, deprecated)
    public func commitEditing(style: UITableViewCell.EditingStyle) {}
    @available(*, deprecated)
    public func onWillBeginEditing() {}
    @available(*, deprecated)
    public func onDidEndEditing() {}
    
    // Menu
    @available(*, deprecated)
    public var shouldShowMenu: Bool = false
    @available(*, deprecated)
    public func canPerformAction(action: Selector, with sender: Any?) -> Bool { false }
    @available(*, deprecated)
    public func performAction(action: Selector, with sender: Any?) {}
    
    // TODO: Focus
    
    // Mutliple selection
    @available(*, deprecated)
    public var shouldBeginMultipleSelectionInteraction: Bool = false
    @available(*, deprecated)
    public func didBeginMultipleSelectionInteraction() {}
}
