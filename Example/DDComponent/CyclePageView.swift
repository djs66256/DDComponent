//
//  CyclePageView.swift
//  BNPlay
//
//  Created by Delon on 2020/6/28.
//

import UIKit

@MainActor
public protocol CyclePageDataSource: AnyObject {
    func prev(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable?
    func next(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable?
}

@MainActor
public protocol CyclePageDelegate: AnyObject {
    func goPrev(_ page: CyclePageView, item: CyclePageItemable) -> Bool
    func goNext(_ page: CyclePageView, item: CyclePageItemable) -> Bool
    func goCurrent(_ page: CyclePageView, item: CyclePageItemable)
    func skipItem(_ page: CyclePageView, item: CyclePageItemable)
    func itemsChanged(_ page: CyclePageView,
                    oldItems: [CyclePageItemable],
                    newItems: [CyclePageItemable])
    func currentWillChanged(_ page: CyclePageView,
                           oldItem: CyclePageItemable?,
                           newItem: CyclePageItemable?)
    func currentChanged(_ page: CyclePageView)
    func currentRefresh(_ page: CyclePageView)
    func itemViewDidLayout(_ page: CyclePageView,
                         itemView: CyclePageItemView)
}

@MainActor
public protocol CyclePageScrollDelegate: AnyObject {
    func scrollViewDidScroll(_ page: CyclePageView)
    func scrollViewWillBeginDragging(_ page: CyclePageView)
    func scrollViewDidEndDragging(_ page: CyclePageView, willDecelerate decelerate: Bool)
    func scrollViewDidEndDecelerating(_ page: CyclePageView)
}

@MainActor
public protocol CyclePageItemView : AnyObject {
    var isCurrent: Bool {get set}
    var displayView: UIView {get}
    func attach(_ item: CyclePageItemable)
    func reuse()
}

@MainActor
public protocol CyclePageItemable: AnyObject {
    var isSkipScroll: Bool {get}
    func isEquals(_ other: CyclePageItemable) -> Bool
    func isCycleEquals(_ other: CyclePageItemable) -> Bool
    func createView() -> CyclePageItemView
    var name: String {get}
}

public extension CyclePageItemable {
    var isSkipScroll: Bool {
        true
    }
    
    var reuseKey: String {
        "\(Self.self)"
    }
}

@MainActor
public func CyclePageItemEquals(_ lhs: CyclePageItemable?, _ rhs: CyclePageItemable?) -> Bool {
    if let lhs = lhs {
        return rhs?.isEquals(lhs) ?? false
    } else {
        return rhs == nil
    }
}

@MainActor
public class CyclePageView: UIView {
    private var _currentItem: CyclePageItemable?
    public var displayItem: CyclePageItemable? {
        viewModel.currentItem
    }
    
    public var currentItem: CyclePageItemable? {
        get {
            _currentItem
        }
        
        set {
            let isItemChange = !CyclePageItemEquals(_currentItem, newValue)
            let oldItem = _currentItem
            
            if isItemChange {
                delegate?.currentWillChanged(self, oldItem: oldItem, newItem: newValue)
            }
            
            _currentItem = newValue
            viewModel.currentItem = newValue
            viewModel.updateCurrent()
            
            if isItemChange {
                delegate?.currentChanged(self)
            } else {
                delegate?.currentRefresh(self)
            }
        }
    }
    
    public var currentItemView: CyclePageItemView? {
        guard let current = currentItem else {
            return nil
        }
        
        return viewModel.itemView(current)
    }
    
    public var itemViews: [CyclePageItemView] {
        return viewModel.itemViews
    }
    
    public var reuseItemViews: [CyclePageItemView] {
        return viewModel.reuseItemViews
    }
    
    private var isEndDecelerating = true
    public weak var dataSource: CyclePageDataSource?
    public weak var delegate: CyclePageDelegate?
    public weak var scrollDelegate: CyclePageScrollDelegate?
    public let scrollView: UIScrollView
    private let containerView = UIView()
    private let viewModel = PageItemViewModel()
    public init(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: CGRect.zero)
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        scrollView.backgroundColor = .clear
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        scrollView.bounces = true
        
        scrollView.contentInsetAdjustmentBehavior = .never
        
        viewModel.prevItem = {[weak self] in
            guard let self = self else {return nil}
            return self.dataSource?.prev(self, current: $0)
        }
        
        viewModel.nextItem = {[weak self] in
            guard let self = self else {return nil}
            return self.dataSource?.next(self, current: $0)
        }
        
        viewModel.itemsChanged = {[weak self] in
            guard let self = self else {return}
            self.delegate?.itemsChanged(self, oldItems: $0, newItems: $1)
        }
        
        viewModel.addView = {[weak self] in
            guard let self = self, $0.superview == nil else {return}
            self.containerView.addSubview($0)
        }
        
        viewModel.beforeLayoutItems = {[weak self](total,offset)in
            guard let self = self else {return}
            UIView.performWithoutAnimation {
                self.containerView.size = CGSize(width: self.scrollView.bounds.width, height: total)
                self.scrollView.contentSize = self.containerView.size
                self.scrollView.contentOffset.y = offset
            }
        }
        
        viewModel.didLayoutItemView = { [weak self] in
            guard let self = self else {return}
            self.delegate?.itemViewDidLayout(self, itemView: $0)
        }
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        viewModel.itemSize = bounds.size
        viewModel.updatePageItems()
        viewModel.updateCurrent()
    }

    public func resetPageItems() {
        viewModel.resetPageItems()
    }
    
    public func clearPageItems() {
        viewModel.clearPageItems()
    }
    
    public func displayPageItem(offset: CGFloat) {
        viewModel.onScroll(offset)
    }
    
    public func endScroll() {
        if !isEndDecelerating {
            isEndDecelerating = true
            updateCurrentItem(scrollView)
        }
    }
}

extension CyclePageView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.onScroll(scrollView.contentOffset.y)
        scrollDelegate?.scrollViewDidScroll(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !isEndDecelerating {
            updateCurrentItem(scrollView)
        }

        isEndDecelerating = false
        scrollDelegate?.scrollViewWillBeginDragging(self)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isEndDecelerating = true
            updateCurrentItem(scrollView)
        }
        scrollDelegate?.scrollViewDidEndDragging(self, willDecelerate: decelerate)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isEndDecelerating = true
        updateCurrentItem(scrollView)
        scrollDelegate?.scrollViewDidEndDecelerating(self)
    }
}

extension CyclePageView {
    func skipItem(_ item: CyclePageItemable) {
        guard viewModel.currentItem !== item else {
            return
        }
        
        viewModel.currentItem = item
        delegate?.skipItem(self, item: item)
    }
    
    func goPrev(_ item: CyclePageItemable, fromItem: CyclePageItemable) {
        guard currentItem !== item else {
            skipItem(item)
            return
        }
       
        if delegate?.goPrev(self, item: fromItem) == false {
            goCurrent(fromItem)
        }
    }
    
    func goNext(_ item: CyclePageItemable, fromItem: CyclePageItemable) {
        guard currentItem !== item else {
            skipItem(item)
            return
        }
            
        if delegate?.goNext(self, item: fromItem) == false {
            goCurrent(fromItem)
        }
    }
    
    func goCurrent(_ item: CyclePageItemable) {
        guard currentItem !== item else {
            skipItem(item)
            return
        }
        
        delegate?.goCurrent(self, item: item)
    }
    
    func updateCurrentItem(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        let index = Int(y / scrollView.height + 0.5)
        let items = viewModel.pageItems.compactMap {$0.item}
        guard index >= 0, index < items.count else {
            return
        }
    
        let item = items[index]
        let currentIndex = items.firstIndex{viewModel.currentItem?.isEquals($0) ?? false}
        if isEndDecelerating {
            if let currentIndex = currentIndex {
               if currentIndex > index {
                   goPrev(item, fromItem: items[currentIndex])
               } else if currentIndex < index {
                   goNext(item, fromItem: items[currentIndex])
               } else {
                   goCurrent(item)
               }
            } else {
                goCurrent(item)
            }
        } else {
            if item.isSkipScroll {
                skipItem(item)
            } else {
                goCurrent(item)
            }
        }
    }
}

@MainActor
class PageItemViewModel {
    typealias FinishLayoutBlock = (CGFloat,CGFloat) -> Void
    typealias BeforeLayoutItemsBlock = (CGFloat,CGFloat) -> Void
    typealias ItemViewBlock = (CyclePageItemView) -> Void
    typealias AddViewBlock = (UIView) -> Void
    typealias ItemIterBlock = (CyclePageItemable) -> CyclePageItemable?
    typealias ItemsChangedBlock = ([CyclePageItemable],[CyclePageItemable]) -> Void
    @MainActor
    class PageItem: Equatable {
        var item: CyclePageItemable?
        var view: CyclePageItemView?
        var frame: CGRect
        var isCurrent = false {
            didSet {
                guard let view = view, view.isCurrent != isCurrent else {
                    return
                }
                
                view.isCurrent = isCurrent
            }
        }
        
        init(_ item: CyclePageItemable? = nil,
             view: CyclePageItemView? = nil,
             frame: CGRect = CGRect.zero) {
            self.item  = item
            self.view  = view
            self.frame = frame
        }
        
        static func == (lhs: PageItem, rhs: PageItem) -> Bool {
            CyclePageItemEquals(lhs.item, rhs.item)
        }
    }
    
    var itemSize = CGSize.zero
    var finishLayout: FinishLayoutBlock?
    var beforeLayoutItems: BeforeLayoutItemsBlock?
    var didLayoutItemView: ItemViewBlock?
    var addView: AddViewBlock?
    var prevItem: ItemIterBlock?
    var nextItem: ItemIterBlock?
    var itemsChanged: ItemsChangedBlock?
    private(set) var pageItems = [PageItem]()
    private var reuseViews = [String:[CyclePageItemView]]()
    var currentItem: CyclePageItemable? {
        didSet {
            let oldPageItems = pageItems
            if updatePageItems() {
                itemsChanged?(oldPageItems.compactMap{$0.item}, pageItems.compactMap{$0.item})
            }
        }
    }
    
    var itemViews: [CyclePageItemView] {
       pageItems.compactMap {$0.view}
    }
    
    var reuseItemViews: [CyclePageItemView] {
        reuseViews.reduce([], {$0+$1.value})
    }
    
    func itemView(_ item: CyclePageItemable) -> CyclePageItemView? {
        return pageItems.first(where: {$0.item?.isEquals(item) ?? false})?.view
    }
    
    func updateCurrent() {
        guard let currentItem = currentItem else {return}
        
        pageItems.forEach {
            $0.isCurrent = $0.item?.isEquals(currentItem) ?? false
        }
    }
    
    func reuseView(_ item: CyclePageItemable) -> CyclePageItemView? {
        let reuseKey = item.reuseKey
        if var reuseViews = self.reuseViews[reuseKey] {
            let reuseView = reuseViews.popLast()
            self.reuseViews[reuseKey] = reuseViews
            return reuseView
        }
        
        return nil
    }
    
    @discardableResult
    func updatePageItems() -> Bool {
        let oldPageItems = pageItems
        let newPageItems = createPageItems()
        clearPageItems()
        
        pageItems = newPageItems
        layoutPageItems()
        
        return oldPageItems != newPageItems
    }
    
    func createPageItems() -> [PageItem] {
        var pageItems = [PageItem]()
        if let currentItem = currentItem {
           var offset: CGFloat = 0
           if let prev = prevItem?(currentItem) {
               pageItems.append(PageItem(prev,
                                         view: cycleView(prev),
                                         frame: CGRect(origin: CGPoint.zero, size: itemSize)))
               offset += itemSize.height
           } else {
               pageItems.append(PageItem())
           }
           
           pageItems.append(PageItem(currentItem,
                                     view: cycleView(currentItem),
                                     frame: CGRect(origin: CGPoint(x: 0, y: offset), size: itemSize)))
           
           offset += itemSize.height
               
           if let next = nextItem?(currentItem) {
               pageItems.append(PageItem(next,
                                         view: cycleView(next),
                                         frame: CGRect(origin: CGPoint(x: 0, y: offset), size: itemSize)))
           } else {
               pageItems.append(PageItem(frame: CGRect(origin: CGPoint(x: 0, y: offset), size: CGSize.zero)))
           }
        }
        
        return pageItems
    }

    func resetPageItems() {
        pageItems.removeAll() {
            if let view = $0.view {
                view.displayView.removeFromSuperview()
            }
            return true
        }
        reuseViews.removeAll()

        pageItems = createPageItems()
        updateCurrent()
        layoutPageItems()
    }
    
    func clearPageItems() {
        pageItems.removeAll {
            guard let view = $0.view else {return true}
            if let item = $0.item {
                view.reuse()
                view.displayView.isHidden = true
                
                let reuseKey = item.reuseKey
                if var reuseViews = self.reuseViews[reuseKey] {
                    reuseViews.append(view)
                    self.reuseViews[reuseKey] = reuseViews
                } else {
                    self.reuseViews[reuseKey] = [view]
                }
            } else {
                view.displayView.removeFromSuperview()
            }
            
            return true
        }
    }
    
    func layoutPageItems() {
        var offset: CGFloat = 0
        var total: CGFloat = 0
        pageItems.forEach {
            if currentItem === $0.item {
                offset = $0.frame.origin.y
            }
            total += $0.frame.size.height
        }
        // add完subview再调整scrollView的contentView的size有时会引起itemView frame变更，所以先调整scrollView的contentView的size
        beforeLayoutItems?(total,offset)
        pageItems.forEach {
            if currentItem === $0.item {
                if $0.view == nil {
                    displayItem($0)
                } else {
                    layoutItem($0)
                }
            } else {
                layoutItem($0)
            }
        }
        finishLayout?(total,offset)
    }
    
    func onScroll(_ offset: CGFloat) {
        let frame = CGRect(origin: CGPoint(x: 0, y: offset), size: itemSize)
        UIView.performWithoutAnimation {
            pageItems.forEach {
                if $0.frame.intersects(frame) {
                    displayItem($0)
                }
            }
        }
    }
    
    func layoutItem(_ pageItem: PageItem) {
        if let view = pageItem.view {
            let displayView = view.displayView
            addView?(displayView)
            displayView.frame = pageItem.frame
            
            displayView.isHidden = false
            didLayoutItemView?(view)
        }
    }
    
    func displayItem(_ pageItem: PageItem) {
        if let item = pageItem.item, pageItem.view == nil {
            let view = reuseView(item) ?? item.createView()
            pageItem.view = view
            
            let displayView = view.displayView
            addView?(displayView)
            displayView.frame = pageItem.frame
            
            view.attach(item)
            view.isCurrent = pageItem.isCurrent
            
            displayView.isHidden = false
            didLayoutItemView?(view)
        }
    }
    
    func cycleView(_ item: CyclePageItemable) -> CyclePageItemView? {
        if let index = pageItems.firstIndex(where: {
            return ($0.item?.isEquals(item) ?? false) && $0.view != nil
        }) {
            let view = pageItems[index].view
            pageItems.remove(at: index)
            return view
        }
    
        if let index = pageItems.firstIndex(where: {
            return ($0.item?.isCycleEquals(item) ?? false) && $0.view != nil && $0.isCurrent
        }) {
            let view = pageItems[index].view
            pageItems.remove(at: index)
            return view
        }
    
        return nil
    }
}
