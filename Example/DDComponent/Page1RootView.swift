//
//  Page1RootView.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/8/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Then

class Page1RootView: UIView, Page1RootPresenterView {
    var view1: View1PresentableView {
        _view1
    }
    let _view1 = View1()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        addSubview(_view1)
        _view1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

