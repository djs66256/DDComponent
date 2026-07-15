//
//  Page1RootPresenter.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/8/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import DDComponent

protocol Page1RootPresenterView {
    var view1: View1PresentableView { get }
}

class Page1RootPresenter: RootViewPresenter<Page1RootPresenterView> {
    typealias View = Page1RootPresenterView
    
    required init() {
        super.init()
        
        typeBox(View1Presenter())
    }
    
    var model: Page1Model? {
        didSet {
            if let model = model,
               let p1 = getViewPresenter(ObjectIdentifier(View1Presentable.self)) as? View1Presentable {
                p1.isLiked = model.isLiked
                p1.likeCount = model.likeCount
                p1.commentCount = model.commentCount
            }
        }
    }
    
    func loadData() {
        if let loader = getService(Page1DataLoader.self) {
            loader.loadData { model, error in
                if let model = model {
                    setState {
                        self.model = model
                    } context: {
                        $0.animated = false
                    }
                }
            }
        }
    }
    
    override func onAttach() {
        super.onAttach()
        
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        
//        let p1: View1Presenter? = getViewPresenter(ObjectIdentifier(View1Presenter.self))
//        p1?.bindView(view.view1)
    }
    
    override func onDetach() {
//        removeAllListeners()
    }
}

extension Page1RootPresenter: Page1LikeListener {
    func onLikeWillChange(id: String, isLiked: Bool, likeCount: Int) {
    }
    
    func onLikeDidChange(id: String, isLiked: Bool, likeCount: Int) {
        model?.isLiked = isLiked
        model?.likeCount = likeCount
        print("Model like changed!")
    }
    
    
}
