//
//  UICollectionViewReusablePresenter.swift
//  DDComponent
//
//  Created by daniel on 2023/9/22.
//

import Foundation
import UIKit

open class UICollectionViewFlowItemPresenterHolder<P, View>
    : CollectionItemReusablePresenterHolder<P, View>, UICollectionItemFlowPresentable
where View: UICollectionReusableView, P: ReusablePresentable, P: ReusableViewPresenter<View> {
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

open class UICollectionViewReusableFlowItemPresenter<View>: ReusableViewPresenter<View>, UICollectionItemSizeCalculatable {
    public var layoutInfo = UICollectionItemFlowLayoutInfo()
    
    open func calculateSize(containerSize: CGSize) -> CGSize {
        .zero
    }
}
