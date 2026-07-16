//
//  UICollectionViewPresentable.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation
import UIKit

// MARK: - Presenter

/// ItemPresenter for UICollectionView
@MainActor
public protocol UICollectionViewItemPresentable: CollectionItemPresentable {
    var canMove: Bool { get }
    
    var shouldHighlight: Bool { get }
    func onDidHighlighted()
    func onDidUnhighlight()
    
    var shouldSelect: Bool { get }
    var shouldDeselect: Bool { get }
    func onDidSelect()
    func onDidDeselect()
    
    func onWillDisplay()
    func onDidEndDisplaying()
}

// MARK: - UICollectionViewFlowLayout
/// Config flow layout for item
public struct UICollectionItemFlowLayoutInfo: UICollectionViewLayoutInfo {
    public enum LayoutType {
        case autoLayout, sizeThatFits, intrinsicContentSize
    }
    
    public enum SizeFitting {
        case auto               // Using finity container width/height to make constraints
        case containerWidth     // Using container width to make constraints
        case containerHeight    // Using container height to make constraints
        case containerSize      // Using container width and height to make constraints
        case unlimited          // Do not make width and height constraints
    }
    
    /// calculate item size automatically, otherwise should override
    /// `func calculateSize(containerSize: CGSize) -> CGSize` to calculate manually
    public var calculateSizeAutomatically: Bool = true
    
    /// Distinguish which algorithm to be used for auto calculation.
    public var layoutType: LayoutType = .autoLayout
    
    // SizeFitting defines the container size when using `autoLayout`
    public var autoLayoutSizeFitting: SizeFitting = .auto
    public init() {}
}

@MainActor
public protocol UICollectionItemSizeCaculatable: ViewPresentable {
    var layoutInfo: UICollectionItemFlowLayoutInfo { get }
    
    /// Calculate size manually
    /// - Returns: content size
    func calculateSize(containerSize: CGSize) -> CGSize
}

@MainActor
public protocol UICollectionItemFlowPresentable: UICollectionViewItemPresentable {
    var layoutInfo: UICollectionItemFlowLayoutInfo { get }
    
    /// Calculate size manually
    /// - Returns: content size
    func calculateSize(containerSize: CGSize) -> CGSize
}

/// ItemPresenter for UICollectionView with flow layout.
open class UICollectionViewFlowItemPresenter<View: UICollectionReusableView>: CollectionItemPresenter<View>, UICollectionItemFlowPresentable {
    public var layoutInfo = UICollectionItemFlowLayoutInfo()
    
    open func calculateSize(containerSize: CGSize) -> CGSize {
        .zero
    }
    
    public var canMove: Bool = false
    
    public var shouldHighlight: Bool = true
    open func onDidHighlighted() {}
    open func onDidUnhighlight() {}
    
    public var shouldSelect: Bool = true
    public var shouldDeselect: Bool = true
    open func onDidSelect() {}
    open func onDidDeselect() {}
    
    open func onWillDisplay() {}
    open func onDidEndDisplaying() {}
}

public extension UICollectionItemFlowPresentable {
    func calculateSize(containerSize: CGSize) -> CGSize {
        .zero
    }
}

// MARK: - Helper

public extension UICollectionViewItemPresentable {
    var canMove: Bool { false }
    var shouldHighlight: Bool { false }
    func onDidHighlighted() {}
    func onDidUnhighlight() {}
    
    var shouldSelect: Bool { false }
    var shouldDeselect: Bool { false }
    func onDidSelect() {}
    func onDidDeselect() {}
    
    func onWillDisplay() {}
    func onDidEndDisplaying() {}
    
    var selectedInCollectionView: Bool {
        get {
            collectionViewPresenter?.isSelected(for: self) ?? false
        }
        set {
            if newValue {
                collectionViewPresenter?.select(presenter: self,
                                                animated: false,
                                                scrollPosition: [.centeredHorizontally, .centeredVertically])
            }
            else {
                collectionViewPresenter?.deselect(presenter: self, animated: false)
            }
        }
    }
    
    func selectedInCollectionView(animated: Bool,
                                  scrollPosition: UICollectionView.ScrollPosition) {
        collectionViewPresenter?.select(presenter: self,
                                        animated: animated,
                                        scrollPosition: scrollPosition)
    }
    
    func deselectedInCollectionView(animated: Bool) {
        collectionViewPresenter?.deselect(presenter: self, animated: animated)
    }
    
    func scrollToVisible(position: UICollectionView.ScrollPosition, animated: Bool) {
        collectionViewPresenter?.scrollToVisible(for: self, position: position, animated: animated)
    }
    
    func scrollToVisible(inset: UIEdgeInsets = .zero, animated: Bool) {
        collectionViewPresenter?.scrollToVisible(for: self, inset: inset, animated: animated)
    }
    
    func findLayoutAttributes() -> UICollectionViewLayoutAttributes? {
        collectionViewPresenter?.layoutAttributes(for: self)
    }
    
    var collectionViewPresenter: UICollectionViewPresentable? {
        var p: ViewPresentable = self
        while let superPresenter = p.superPresenter {
            if let collectionViewPresenter = superPresenter as? UICollectionViewPresentable {
                return collectionViewPresenter
            }
            p = superPresenter
        }
        return nil
    }
}
