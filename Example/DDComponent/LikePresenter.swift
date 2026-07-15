//
//  LikePresenter.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/19.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import DDComponent

protocol LikableResourceProtocol {
    var id: String { get }
}

protocol LikeService {
    func toggleLike(resource: LikableResourceProtocol,
                    isLiked: Bool,
                    likeCount: Int,
                    _ callback: (Bool, Int, Error?)->Void)
}

protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { set get }
    var likeCount: Int { set get }
    
    func set(isLiked: Bool, animated: Bool)
    
    var onLikeTapped: (()->Void)? { set get }
}

protocol LikePresenterListener: AnyObject {
    func onLikeInfoChanged(presenter: LikePresenter, isLiked: Bool, likeCount: Int)
}

class LikePresenter: ViewPresenter<LikeViewProtocol> {
    
    var resource: LikableResourceProtocol?
    
    struct LikeInfo {
        var isLiked: Bool = false
        var likeCount: Int = 0
    }
    
    var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        set {
            setState {
                _likeInfo = newValue
            } context: {
                $0.animated = false
            }
        }
        get {
            _likeInfo
        }
    }
    
    func set(likeInfo: LikeInfo, animated: Bool) {
        setState {
            _likeInfo = likeInfo
        } context: {
            $0.animated = animated
        }
    }
    
    func toggleLike() {
        if let resource = resource, let service = getService(LikeService.self) {
            service.toggleLike(resource: resource,
                               isLiked: likeInfo.isLiked,
                               likeCount: likeInfo.likeCount) { [weak self] isLiked, likeCount, error in
                if let error = error {
                    // handle error
                }
                else {
                    if let self = self {
                        self.set(likeInfo: LikeInfo(isLiked: isLiked, likeCount: likeCount),
                                 animated: true)
                        notify(listener: LikePresenterListener.self) {
                            $0.onLikeInfoChanged(presenter: self, isLiked: isLiked, likeCount: likeCount)
                        }
                    }
                }
            }
        }
    }
    
    override func onBindView(_ view: LikeViewProtocol) {
        super.onBindView(view)
        view.onLikeTapped = { [weak self] in
            self?.toggleLike()
        }
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        view?.onLikeTapped = nil
    }
}
