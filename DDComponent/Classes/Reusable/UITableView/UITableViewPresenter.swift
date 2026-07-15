//
// JDilla
// Created by Bytedance on 2023/12/3.
//


import Foundation

public protocol UITableViewPresentable: CollectionPresentable {
    
    var proxy: UITableViewDelegateProxy? { get }
    
    var displayIndexTitles: Bool { get set }
    
    func didEndMultipleSelectionInteraction()
}

@MainActor
open class UITableViewPresenter<V: UITableView>: CollectionPresenter<V>, UITableViewPresentable {
    
    public weak var scrollDelegate: UIScrollViewDelegate? {
        didSet { proxy?.scrollDelegate = scrollDelegate }
    }
    
    public var proxy: UITableViewDelegateProxy?
    
    public override var viewUpdatePipeline: ViewUpdatePipeline? {
        proxy?.updatePipline
    }
    
    open override func bindView(_ view: V) {
        super.bindView(view)
        setupView(view)
    }
    
    open override func bindWeakView(_ view: V) {
        super.bindWeakView(view)
        setupView(view)
    }
    
    private func setupView(_ view: V) {
        if scrollDelegate == nil {
            scrollDelegate = view.delegate
        }
        proxy = UITableViewDelegateProxy(root: self, tableView: view)
        if let scrollDelegate {
            proxy?.scrollDelegate = scrollDelegate
        }
        self.proxy?.updatePipline.superPipeline = superPresenter?.viewUpdatePipeline
        setState {} context: {
            $0.reloadData()
            $0.forceDisableAnimation = true
        }
    }
    
    public override func unbindView() {
        super.unbindView()
        self.proxy?.updatePipline.superPipeline = nil
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
    
    public var displayIndexTitles: Bool =  false
    
    open func didEndMultipleSelectionInteraction() {}
}
