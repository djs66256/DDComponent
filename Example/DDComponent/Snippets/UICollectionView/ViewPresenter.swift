//
//  ViewPresenter.swift
//  DDComponent_Example
//
//  Created by daniel on 2023/11/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import DDComponent

class XXXCollectionCellPresenter: UICollectionViewFlowItemPresenter<XXXCollectionCell> {
    typealias View = XXXCollectionCell
    
    override init() {
        super.init()
        
        // layoutInfo.calculateSizeAutomatically = false
        // layoutInfo.layoutType = .sizeThatFits
    }
    
    private struct State {
        // Manage all view state. When state changed, view will update automatically.
    }
    
    private var state = State() {
        didSet { setState {} }
    }
    
    override func onBindView(_ view: View) {
        super.onBindView(view)
        
        // view.delegate = self
    }
    
    override func onUnbindView() {
        super.onUnbindView()
        
        // view?.delegate = nil
    }
    
    override func onUpdate(view: View, context: ViewUpdateContext) {
        // Update view with state
    }
    
    // override func calculateSize(containerSize: CGSize) -> CGSize {
    //     return CGSize(width: containerSize.width, height: containerSize.height)
    // }
}
