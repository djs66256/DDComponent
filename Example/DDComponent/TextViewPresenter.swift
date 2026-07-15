//
//  TextViewPresenter.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import DDComponent

protocol TextView: AnyObject {
    var text: String? { get set }
}

class CollectionTextViewCell: UICollectionViewCell, TextView {
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.numberOfLines = 0
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionTextReusableView: UICollectionReusableView, TextView {
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.numberOfLines = 0
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionTextViewCellPresenter: CollectionItemPresenter<CollectionTextViewCell>, UICollectionItemFlowPresentable {
    var layoutInfo = UICollectionItemFlowLayoutInfo()
    
    var _text: String?
    var text: String? {
        get {
            _text
        }
        set {
            setText(newValue)
        }
    }
    func setText(_ text: String?, animated: Bool = false) {
        setState {
            _text = text
        } context: {
            $0.invalidateContentSize = true
            $0.animated = true
        }
    }
    
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true
    }
    
    override func onUpdate(view: CollectionTextViewCell, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        view.text = text
    }
    
}

class TextViewPresenter: ViewPresenter<TextView> {
    var text: String? {
        didSet {
            setState {}
        }
    }
    
    override func onUpdate(view: TextView, context: ViewUpdateContext) {
        super.onUpdate(view: view, context: context)
        view.text = text
    }
}
