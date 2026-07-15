//
//  Page1LikeService.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/1.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

protocol Page1LikeService {
    func toggleLike(id: String,
                    isLiked: Bool,
                    likeCount: Int,
                    _ completion: @escaping (_ liked: Bool, _ likeCount: Int)->Void)
}

class Page1LikeServiceImpl: Page1LikeService {
    func toggleLike(id: String, isLiked: Bool, likeCount: Int, _ completion: @escaping (_ liked: Bool, _ likeCount: Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            completion(!isLiked, !isLiked ? likeCount+1 : likeCount - 1)
        }
    }
}
