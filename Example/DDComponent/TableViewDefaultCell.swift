//
//  TableViewDefaultCell.swift
//  DDComponent_Example
//
//  Created by daniel on 2023/9/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import DDComponent
import SnapKit

protocol TableViewDefaultCellable: AnyObject {
    var title: TextView { get }
    var detail: TextView { get }
}

class TableViewDefaultCellPresenter: UITableViewItemReusablePresenter<TableViewDefaultCell> {

    var imagePresenter = ImagePresenter()
    var titlePresenter = TextViewPresenter()
    var detailPresenter = TextViewPresenter()
    
    required init() {
        super.init()
        
        add(child: imagePresenter)
        add(child: titlePresenter)
        add(child: detailPresenter)
    }
    
    var model: TableCellModel? {
        didSet {
            imagePresenter.url = model?.image
            titlePresenter.text = model?.text
            detailPresenter.text = model?.detail
        }
    }
    
    override func onBindView(_ view: TableViewDefaultCell) {
        super.onBindView(view)
        titlePresenter.bindView(view.title)
        detailPresenter.bindView(view.detail)
    }
    
    override func prepareForReuse() {
        
    }
}

class TableTextView: UILabel, TextView {
    
}

class TableImageView: UIImageView, CollectionImageView {
    var url: URL?
    
    
}

class TableViewDefaultCell: UITableViewCell, TableViewDefaultCellable {
    var title: TextView {
        _titleView
    }
    var detail: TextView {
        _detailView
    }
    
    var _titleView = TableTextView()
    var _detailView = TableTextView()
    var _imageView = TableImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(_imageView)
        _imageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
            make.height.width.equalTo(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
        
        let contentView = UIView()
        self.contentView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.equalTo(_imageView.snp_rightMargin).offset(10)
            make.right.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(_titleView)
        contentView.addSubview(_detailView)
        
        _titleView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        
        _detailView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(_titleView.snp_bottomMargin).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TableViewDefaultCellPresenterHolder: UITableViewItemPresenterHolder<TableViewDefaultCellPresenter, TableViewDefaultCell> {
    override init() {
        super.init()
//        layoutInfo.calculateSizeAutomatically = false
    }
    
    var model: TableCellModel? {
        didSet {
            setState {}
        }
    }

    override func onUpdate(presenter: TableViewDefaultCellPresenter, context: ViewUpdateContext) {
        presenter.model = model
    }
    
    override func calculateHeight(containerSize: CGSize) -> CGFloat {
        return 60
    }
}
