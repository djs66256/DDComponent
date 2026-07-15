//
//  Page1Model.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/8/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Then

class Page1Model {
    var id: String = "0"
    var title: String?
    var subTitle: String?
    var imageUrl: String?
    var isLiked: Bool = false
    var likeCount: Int = 0
    var commentCount: Int = 0
}

extension Page1Model : Then {
    static func mock1() -> Page1Model {
        Page1Model().then {
            $0.id = "1"
            $0.title = "mock title 1"
            $0.subTitle = "mock sub title 1, with detail descriptions!"
            $0.imageUrl = "mock image 1"
            $0.isLiked = true
            $0.likeCount = 12
            $0.commentCount = 34
        }
    }
}
