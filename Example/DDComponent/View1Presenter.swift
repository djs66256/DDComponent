//
//  View1Presenter.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/8/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import DDComponent

protocol View1Presentable: ViewPresentable {
    var id: String { set get }
    var isLiked: Bool { set get }
    var likeCount: Int { set get }
    var commentCount: Int { set get }
}

protocol View1PresentableViewDelegate: AnyObject {
    func onLike()
    func onComment()
    func onMore()
}

protocol View1PresentableView: AnyObject {
    var delegate: View1PresentableViewDelegate? { set get }
    var isLiked: Bool { set get }
    var likeCount: Int { set get }
    var commentCount: Int { set get }
}


class View1Presenter: ViewPresenter<View1PresentableView> {
    override init() {
        super.init()
        autoBindView = true
    }
    
    typealias View = View1PresentableView
    var id: String = "0"
    var _isLiked: Bool = false
    var isLiked: Bool {
        get { _isLiked }
        set {
            setState {
                _isLiked = newValue
            }
        }
    }
    var _likeCount: Int = 0
    var likeCount: Int {
        get { _likeCount }
        set {
            setState {
                _likeCount = newValue
            }
        }
    }
    var _commentCount: Int = 0
    var commentCount: Int {
        get { _commentCount }
        set {
            setState {
                _commentCount = newValue
            }
        }
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        view.delegate = self
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        view?.delegate = nil
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        
        view.isLiked = isLiked
        view.commentCount = commentCount
        view.likeCount = likeCount
    }
}

protocol Page1LikeListener: AnyObject {
    func onLikeWillChange(id: String, isLiked: Bool, likeCount: Int)
    func onLikeDidChange(id: String, isLiked: Bool, likeCount: Int)
}

extension View1Presenter: View1PresentableViewDelegate {
    func onLike() {
        if let likeService = getService(Page1LikeService.self) {
            likeService.toggleLike(id: id, isLiked: isLiked, likeCount: likeCount) { isLiked, likeCount in
                self.notify(listener: Page1LikeListener.self) {
                    $0.onLikeWillChange(id: self.id, isLiked: isLiked, likeCount: likeCount)
                }
                self.setState {
                    self._isLiked = isLiked
                    self._likeCount = likeCount
                }
                self.notify(listener: Page1LikeListener.self) {
                    $0.onLikeDidChange(id: self.id, isLiked: isLiked, likeCount: likeCount)
                }
            }
        }
    }
    
    func onComment() {
        _ = getService(RouterService.self)?.open(route: "/comment")
    }
    
    func onMore() {
        _ = getService(RouterService.self)?.open(route: "/more")
    }
    
    
}
