//
//  ViewPresenter.swift
//  DDComponent_Example
//
//  Created by daniel on 2023/11/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import DDComponent

// protocol XXXDelegate: AnyObject {
//
// }

protocol XXXViewable: AnyObject {
    
}

class XXXViewPresenter: ViewPresenter<XXXViewable> {
    typealias View = XXXViewable
    
    override init() {
        super.init()
        
        // self.autoBindView = false
        // add(child: <#T##ViewPresentable#>)
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
}
