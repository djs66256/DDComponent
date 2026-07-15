//
//  UICollectionPageViewController.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation

/// PageViewController for UICollectionView, like UICollectionViewController.
open class UICollectionPageViewController<P, V, LayoutType>: PageViewController<V, P, V>, UIScrollViewDelegate
where P: UICollectionViewRootPresenter<V>, V: UICollectionView, LayoutType: UICollectionViewLayout
{
    
    /// Override for custom UICollectionView type
    /// - Returns: UICollectionView instance
    open override func makeView() -> V {
        V(frame: .zero, collectionViewLayout: collectionViewLayout)
    }
    
    public lazy var collectionViewLayout: LayoutType = makeCollectionViewLayout()
    
    /// Override for custom UICollectionViewLayout
    /// - Returns: UICollectionView instance
    open func makeCollectionViewLayout() -> LayoutType {
        LayoutType()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.scrollDelegate = self
    }
}

/// A default implementary of PageViewController for UICollectionView with flow layout
public typealias UICollectionFlowPageViewController
= UICollectionPageViewController<
    UICollectionViewRootPresenter<UICollectionView>,
    UICollectionView,
    UICollectionViewFlowLayout>
