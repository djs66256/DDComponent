//
//  CollectionImageViewPresenter.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import DDComponent

// MARK: - view protocol
protocol CollectionImageView: AnyObject {
    var url: URL? { get set }
}

// MARK: - collection view cell impl
class CollectionImageViewCell: UICollectionViewCell, CollectionImageView {
    var url: URL? {
        didSet {
            imageView.backgroundColor = url == nil ? .gray : .red
        }
    }
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - reusable view impl
class CollectionImageReusableView: UICollectionReusableView, CollectionImageView {
    
    var url: URL? {
        didSet {
            imageView.backgroundColor = url == nil ? .gray : .red
        }
    }
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - collection view cell presenter impl
class CollectionImageCellPresenter: CollectionItemPresenter<CollectionImageViewCell>, UICollectionItemFlowPresentable {
    var layoutInfo = UICollectionItemFlowLayoutInfo()
    
    var url: URL? {
        didSet {
            setState {}
        }
    }
    
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true
    }
    
    override func onUpdate(view: CollectionImageViewCell, context: ViewUpdateContext) {
        view.url = self.url
    }
}

// MARK: - reusable view presenter impl
class ImagePresenter: ViewPresenter<CollectionImageView> {
    var url: URL? {
        didSet {
            setState {}
        }
    }
    
    override func onUpdate(view: CollectionImageView, context: ViewUpdateContext) {
        view.url = self.url
    }
}

// MARK: - reusable presenter with collection view cell impl

class ImageReusablePresenter: ReusableViewPresenter<CollectionImageViewCell> {
    var url: URL? {
        didSet {
            setState {}
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func onUpdate(view: CollectionImageViewCell, context: ViewUpdateContext) {
        view.url = url
    }
}

class ImageReusableCellHolderPresenter: UICollectionViewFlowItemPresenterHolder<ImageReusablePresenter, CollectionImageViewCell> {
    
    var url: URL? {
        didSet {
            setState {}
        }
    }
    
    override func onUpdate(presenter: ImageReusablePresenter, context: ViewUpdateContext) {
        presenter.url = url
    }
}
