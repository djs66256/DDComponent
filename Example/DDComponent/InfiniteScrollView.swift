//
//  InfiniteScrollView.swift
//  DDComponent
//
//  Created by daniel on 2022/9/14.
//

import Foundation
import UIKit

open class PageReusableView: UIView {
    open func prepareForReuse() {
        
    }
}

public protocol PageScrollViewDataSource: AnyObject {
    func currentModel(pageScrollView: PageScrollView) -> Any?
    func nextModel(pageScrollView: PageScrollView, currentModel: Any?) -> Any?
    func prevModel(pageScrollView: PageScrollView, currentModel: Any?) -> Any?
    func reusableView(pageScrollView: PageScrollView, for model: Any) -> PageReusableView?
}

public protocol PageScrollViewDelegate: UIScrollViewDelegate {
    func pageScrollView(_ scrollView: PageScrollView, willChangeTo oldModel: Any?)
    func pageScrollView(_ scrollView: PageScrollView, didChangeFrom oldModel: Any?)
}

open class PageScrollView: UIView, UIScrollViewDelegate {
    public let scrollView = UIScrollView()
    
    public weak var delegate: PageScrollViewDelegate?
    public weak var dataSource: PageScrollViewDataSource?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(scrollView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var ready = false
    func reloadData() {
        currentModel = dataSource?.currentModel(pageScrollView:self)
        nextModel = dataSource?.nextModel(pageScrollView:self, currentModel:currentModel)
        prevModel = dataSource?.prevModel(pageScrollView:self, currentModel:currentModel)
    }
    
    var currentModel: Any?
    var nextModel: Any?
    var prevModel: Any?
    
    var currentView: PageReusableView?
    var nextView: PageReusableView?
    var prevView: PageReusableView?
    
    private var reusableViewMeta: [String: AnyClass] = [:]
    public func registerReusableView(class: AnyClass, for identifier: String) {
        
    }
    
    public func dequeueReusableView<T: PageReusableView>(identifier: String) -> T? {
        return nil
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating {
            if scrollView.contentOffset.y < 0 {
                
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
}
