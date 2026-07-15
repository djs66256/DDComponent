//
//  UITableViewPresentable.swift
//  DDComponent
//
//  Created by daniel on 2023/9/21.
//

import Foundation

/// Config flow layout for item
public struct UITableViewCellLayoutInfo {
    public enum LayoutType {
        case autoLayout, sizeThatFits
    }
    
    /// calculate item size automatically, otherwise should override
    /// `func calculateSize(containerSize: CGSize) -> CGSize` to calculate manually
    public var calculateSizeAutomatically: Bool = true
    
    /// Distinguish which algorithm to be used for auto calculation.
    public var layoutType: LayoutType = .autoLayout
    
    public var estimatedHeight: CGFloat = UITableView.automaticDimension
    
    public init() {}
    
    mutating func apply(_ closure: (inout Self)->Void) {
        closure(&self)
    }
}

@MainActor
public protocol UITableViewItemSizeCaculatable: ViewPresentable {
    var layoutInfo: UITableViewCellLayoutInfo { get }
    
    /// Calculate height manually
    /// - Returns: content height
    func calculateHeight(containerSize: CGSize) -> CGFloat
}

public protocol UITableViewItemPresentable: CollectionItemPresentable {
    var layoutInfo: UITableViewCellLayoutInfo { get set }
    func calculateHeight(containerSize: CGSize) -> CGFloat
    
    // Display
    func onWillDisplay()
    func onDidEndDisplaying()
    
    // Highlight & select
    var shouldHighlight: Bool { get set }
    func onDidHighlight()
    func onDidUnhighlight()
    func onWillSelect()
    func onWillDeselect()
    func onDidSelect()
    func onDidDeselect()
    
    // Edit
    var canEdit: Bool { get set }
    var editStyle: UITableViewCell.EditingStyle { get set }
    var deleteConfirmationButtonTitle: String? { get set }
    @available(iOS, introduced: 8.0, deprecated: 13.0)
    var editActions: [UITableViewRowAction]? { get set }
    var leadingSwipeActionsConfiguration: UISwipeActionsConfiguration? { get set }
    var trailingSwipeActionsConfiguration: UISwipeActionsConfiguration? { get set }
    var shouldIndentWhileEditing: Bool { get set }
    func commitEditing(style: UITableViewCell.EditingStyle)
    func onWillBeginEditing()
    func onDidEndEditing()
    
    // Menu
    var shouldShowMenu: Bool { get set }
    func canPerformAction(action: Selector, with sender: Any?) -> Bool
    func performAction(action: Selector, with sender: Any?)
    
    // TODO: Focus
    
    // Mutliple selection
    var shouldBeginMultipleSelectionInteraction: Bool { get set }
    func didBeginMultipleSelectionInteraction()
    
    // TODO: Preview
}

open class UITableViewItemPresenter<V: UITableViewCell>: CollectionItemPresenter<V>, UITableViewItemPresentable, UITableViewItemSizeCaculatable {
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

@MainActor
public extension UITableViewItemPresentable {
    var tableViewPresenter: UITableViewPresentable? {
        var p: ViewPresentable? = superPresenter
        while p != nil {
            if let tp = p as? UITableViewPresentable {
                return tp
            }
            p = p?.superPresenter
        }
        return nil
    }
    
    func findFrameInTableView() -> CGRect? {
        tableViewPresenter?.proxy?.rect(for: self)
    }
    
    func selectInTableView(animated: Bool,
                           scrollPosition: UITableView.ScrollPosition) {
        tableViewPresenter?.proxy?.selectRow(for: self,
                                             animated: animated,
                                             scrollPosition: scrollPosition)
    }
    
    func deselectRow(animated: Bool) {
        tableViewPresenter?.proxy?.deselectRow(for: self, animated: animated)
    }
    
    func scrollToVisible(at position: UITableView.ScrollPosition, animated: Bool) {
        tableViewPresenter?.proxy?.scrollToRow(for: self, at: position, animated: animated)
    }
    
    func scrollToVisible(inset: UIEdgeInsets = .zero, animated: Bool) {
        tableViewPresenter?.proxy?.scrollToVisible(for: self, inset: inset, animated: animated)
    }
}
