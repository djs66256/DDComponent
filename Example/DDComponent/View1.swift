//
//  View1.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/8/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Then
import SnapKit

class View1: UIView, View1PresentableView {
    weak var delegate: View1PresentableViewDelegate?
    
    var isLiked: Bool = false {
        didSet {
            likeButton.isSelected = isLiked
        }
    }
    var commentCount: Int = 0 {
        didSet {
            commentButton.setTitle("Comment(\(commentCount))", for: .normal)
        }
    }
    
    var likeCount: Int = 0 {
        didSet {
            likeButton.setTitle("Like(\(likeCount))", for: .normal)
            likeButton.setTitle("Like(\(likeCount))", for: .selected)
        }
    }
    
    let likeButton = UIButton().then {
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.red, for: .selected)
        $0.addTarget(self, action: #selector(onLike), for: .touchUpInside)
    }
    let commentButton = UIButton().then {
        $0.setTitleColor(.gray, for: .normal)
        $0.addTarget(self, action: #selector(onComment), for: .touchUpInside)
    }
    let moreButton = UIButton().then {
        $0.setTitleColor(.gray, for: .normal)
        $0.setTitle("More...", for: .normal)
        $0.addTarget(self, action: #selector(onMore), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(moreButton)
        
        likeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(commentButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func onLike() {
        delegate?.onLike()
    }
    @objc
    func onComment() {
        delegate?.onComment()
    }
    @objc
    func onMore() {
        delegate?.onMore()
    }
}
