//
//  UITableViewReusablePresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/9/22.
//

import Foundation
import UIKit

open class UITableViewItemPresenterHolder<P, V>: CollectionItemReusablePresenterHolder<P, V>, UITableViewItemPresentable
where P: ReusablePresentable, P: ReusableViewPresenter<V>, V: UITableViewCell {
    public var layoutInfo = UITableViewCellLayoutInfo()
    open func calculateHeight(containerSize: CGSize) -> CGFloat { 0 }
    
    // Display
    open func onWillDisplay() {}
    open func onDidEndDisplaying() {}
    
    // Highlight & select
    public var shouldHighlight: Bool = false
    open func onDidHighlight() {}
    open func onDidUnhighlight() {}
    open func onWillSelect() {}
    open func onWillDeselect() {}
    open func onDidSelect() {}
    open func onDidDeselect() {}
    
    // Edit
    public var canEdit: Bool = false
    public var editStyle: UITableViewCell.EditingStyle = .none
    public var deleteConfirmationButtonTitle: String? = nil
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    public var editActions: [UITableViewRowAction]? = nil
    public var leadingSwipeActionsConfiguration: UISwipeActionsConfiguration? = nil
    public var trailingSwipeActionsConfiguration: UISwipeActionsConfiguration? = nil
    public var shouldIndentWhileEditing: Bool = false
    open func commitEditing(style: UITableViewCell.EditingStyle) {}
    open func onWillBeginEditing() {}
    open func onDidEndEditing() {}
    
    // Menu
    public var shouldShowMenu: Bool = false
    open func canPerformAction(action: Selector, with sender: Any?) -> Bool { false }
    open func performAction(action: Selector, with sender: Any?) {}
    
    // TODO: Focus
    
    // Mutliple selection
    public var shouldBeginMultipleSelectionInteraction: Bool = false
    open func didBeginMultipleSelectionInteraction() {}
    
}

open class UITableViewItemReusablePresenter<View>: ReusableViewPresenter<View>, UITableViewItemSizeCaculatable {
    public var layoutInfo = UITableViewCellLayoutInfo()
    
    open func calculateHeight(containerSize: CGSize) -> CGFloat { 0 }
}
