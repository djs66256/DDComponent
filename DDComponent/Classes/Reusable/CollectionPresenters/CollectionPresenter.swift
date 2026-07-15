//
// JDilla
// Created by Bytedance on 2023/12/3.
//


import Foundation

open class CollectionPresenter<View>: ViewPresenter<View>, CollectionPresentable {
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
            // Only new section needs adding child.
            if section.superPresenter !== self {
                add(child: section)
            }
        }
        setState(updater: {}, context: {
            $0.reloadData()
            $0.animated = animated
            $0.forceDisableAnimation = !animated
        }, completion: completion)
    }
}
