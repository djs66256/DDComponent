//
//  CollectionRootPresenter.swift
//  DDComponent
//
//  Created by daniel on 2022/9/19.
//

import Foundation
import UIKit

open class CollectionRootPresenter<View>: RootViewPresenter<View>, CollectionRootPresentable {
    private var _sections: [CollectionSectionPresentable] = []
    public var sections: [CollectionSectionPresentable] {
        get { _sections }
        set { setSections(newValue) }
    }
    
    public func setSections(_ sections: [CollectionSectionPresentable], animated: Bool = false, completion: (()->Void)? = nil) {
        let oldValue = _sections
        let newSet = Set(sections.map({ ObjectIdentifier($0) }))
        for old in oldValue {
            if !newSet.contains(ObjectIdentifier(old)) {
                remove(child: old)
            }
        }
        _sections = sections
        for section in sections {
            add(child: section)
        }
        setState(updater: {}, context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }, completion: completion)
    }
}
