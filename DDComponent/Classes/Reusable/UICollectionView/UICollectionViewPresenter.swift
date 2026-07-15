//
// JDilla
// Created by Bytedance on 2023/12/3.
//


import Foundation

public protocol UICollectionViewPresentable: CollectionPresentable {
    
    var collectionView: UICollectionView? { get }
    var proxy: UICollectionViewDelegateProxy? { get }
    
    func isSelected(for presenter: UICollectionViewItemPresentable) -> Bool
    func select(presenter: UICollectionViewItemPresentable,
                animated: Bool,
                scrollPosition: UICollectionView.ScrollPosition)
    func deselect(presenter: UICollectionViewItemPresentable,
                  animated: Bool)
    
    func layoutAttributes(for presenter: UICollectionViewItemPresentable) -> UICollectionViewLayoutAttributes?
    func scrollToVisible(for presenter: UICollectionViewItemPresentable,
                         position: UICollectionView.ScrollPosition,
                         animated: Bool)
    func scrollToVisible(for presenter: UICollectionViewItemPresentable,
                         inset: UIEdgeInsets,
                         animated: Bool)
}

open class UICollectionViewPresenter<V: UICollectionView>: CollectionPresenter<V>, UICollectionViewPresentable {
    
    public var collectionView: UICollectionView? {
        view
    }
    
    public var defaultLayoutProxyType: UICollectionViewDelegateProxy.Type?
    
    public weak var scrollDelegate: UIScrollViewDelegate? {
        didSet { proxy?.scrollDelegate = scrollDelegate }
    }
    
    public var proxy: UICollectionViewDelegateProxy?
    
    public override var viewUpdatePipeline: ViewUpdatePipeline? {
        proxy?.updatePipline
    }
    
    open func bindView(_ view: V, layoutProxy: UICollectionViewDelegateProxy.Type) {
        super.bindView(view)
        setupView(view, proxy: layoutProxy.init(root: self, collectionView: view))
    }
    
    open override func bindView(_ view: V) {
        super.bindView(view)
        setupView(view)
    }
    
    open override func bindWeakView(_ view: V) {
        super.bindWeakView(view)
        setupView(view)
    }
    
    private func setupView(_ view: V, proxy: UICollectionViewDelegateProxy? = nil) {
        if scrollDelegate == nil {
            scrollDelegate = view.delegate
        }
        self.proxy = proxy ??
            defaultLayoutProxyType?.init(root: self, collectionView: view) ??
            UICollectionViewFlowLayoutProxy(root: self, collectionView: view)
        if let scrollDelegate {
            self.proxy?.scrollDelegate = scrollDelegate
        }
        self.proxy?.updatePipline.superPipeline = superPresenter?.viewUpdatePipeline
        setState {} context: {
            $0.reloadData()
            $0.forceDisableAnimation = true
        }
    }
    
    public override func unbindView() {
        super.unbindView()
        proxy?.updatePipline.superPipeline = nil
        proxy?.reset()
        proxy = nil
    }
    
    open override func onAttachToRoot(rootPresenter: RootViewPresentable) {
        super.onAttachToRoot(rootPresenter: rootPresenter)
        viewUpdatePipeline?.superPipeline = superPresenter?.viewUpdatePipeline
    }
    
    open override func onDetachFromRoot() {
        super.onDetachFromRoot()
        viewUpdatePipeline?.superPipeline = nil
    }
    
    public override func updateViewIfNeeded() {
        viewUpdatePipeline?.updateViewIfNeeded(synchronize: true)
    }
    
    public func isSelected(for presenter: UICollectionViewItemPresentable) -> Bool {
        proxy?.isSelected(for: presenter) ?? false
    }
    
    public func select(presenter: UICollectionViewItemPresentable,
                       animated: Bool,
                       scrollPosition: UICollectionView.ScrollPosition) {
        proxy?.select(presenter: presenter, animated: animated, scrollPosition: scrollPosition)
    }
    
    public func deselect(presenter: UICollectionViewItemPresentable,
                         animated: Bool) {
        proxy?.deselect(presenter: presenter, animated: animated)
    }
    
    public func layoutAttributes(for presenter: UICollectionViewItemPresentable) -> UICollectionViewLayoutAttributes? {
        proxy?.layoutAttributes(for: presenter)
    }
    
    public func scrollToVisible(for presenter: UICollectionViewItemPresentable,
                         position: UICollectionView.ScrollPosition,
                                animated: Bool) {
        proxy?.scrollToVisible(for: presenter, position: position, animated: animated)
    }
    
    public func scrollToVisible(for presenter: UICollectionViewItemPresentable, inset: UIEdgeInsets, animated: Bool) {
        proxy?.scrollToVisible(for: presenter, inset: inset, animated: animated)
    }
    
    public func sectionPresenter(at index: Int) -> CollectionSectionPresentable? {
        if let proxy {
            if index < proxy.sectionCount() {
                return proxy.sectionPresenter(at: index)
            }
        }
        return nil
    }
    
    public func itemPresenter(at indexPath: IndexPath) -> CollectionItemPresentable? {
        if let proxy {
            if indexPath.section < proxy.sectionCount() {
                if indexPath.item < proxy.itemCount(at: indexPath.section) {
                    return proxy.itemPresenter(at: indexPath)
                }
            }
        }
        return nil
    }
}


