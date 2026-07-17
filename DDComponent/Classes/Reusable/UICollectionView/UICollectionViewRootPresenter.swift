//
//  UICollectionViewPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/9/27.
//

import UIKit

public protocol UICollectionViewRootPresentable: UICollectionViewPresentable, CollectionRootPresentable {
    
}

open class UICollectionViewRootPresenter<V: UICollectionView>: RootViewPresenter<V>, UICollectionViewRootPresentable {
    
    public let collectionPresenter = UICollectionViewPresenter<V>()
    
    public required init() {
        super.init()
        add(child: collectionPresenter)
    }
    
    public var collectionView: UICollectionView? {
        collectionPresenter.collectionView
    }
    
    public var sections: [CollectionSectionPresentable] {
        get { collectionPresenter.sections }
        set { collectionPresenter.sections = newValue }
    }
    
    public var scrollDelegate: UIScrollViewDelegate? {
        get { collectionPresenter.scrollDelegate }
        set { collectionPresenter.scrollDelegate = newValue }
    }
    
    public var proxy: UICollectionViewDelegateProxy? {
        get { collectionPresenter.proxy }
        set { collectionPresenter.proxy = newValue }
    }
    
    public override var viewUpdatePipeline: ViewUpdatePipeline? {
        collectionPresenter.viewUpdatePipeline
    }
    
    open func bindView(_ view: V, layoutProxy: UICollectionViewDelegateProxy.Type) {
        super.bindView(view)
        collectionPresenter.bindView(view, layoutProxy: layoutProxy)
    }
    
    open override func bindView(_ view: V) {
        super.bindView(view)
        collectionPresenter.bindView(view)
    }
    
    open override func bindWeakView(_ view: V) {
        super.bindWeakView(view)
        collectionPresenter.bindWeakView(view)
    }
    
    public override func unbindView() {
        super.unbindView()
        collectionPresenter.unbindView()
    }
    
    public func isSelected(for presenter: UICollectionViewItemPresentable) -> Bool {
        collectionPresenter.isSelected(for: presenter)
    }
    
    public func select(presenter: UICollectionViewItemPresentable,
                       animated: Bool,
                       scrollPosition: UICollectionView.ScrollPosition) {
        collectionPresenter.select(presenter: presenter, animated: animated, scrollPosition: scrollPosition)
    }
    
    public func deselect(presenter: UICollectionViewItemPresentable,
                         animated: Bool) {
        collectionPresenter.deselect(presenter: presenter, animated: animated)
    }
    
    public func layoutAttributes(for presenter: UICollectionViewItemPresentable) -> UICollectionViewLayoutAttributes? {
        collectionPresenter.layoutAttributes(for: presenter)
    }
    
    public func scrollToVisible(for presenter: UICollectionViewItemPresentable,
                                position: UICollectionView.ScrollPosition,
                                animated: Bool) {
        collectionPresenter.scrollToVisible(for: presenter, position: position, animated: animated)
    }
    
    public func scrollToVisible(for presenter: UICollectionViewItemPresentable, inset: UIEdgeInsets, animated: Bool) {
        collectionPresenter.scrollToVisible(for: presenter, inset: inset, animated: animated)
    }
}


