//
//  DataSource.swift
//  DDComponent
//
//  Created by daniel on 2022/9/18.
//

import Foundation
import UIKit


protocol EngineViewPresenterReadable {
    var presenter: ViewPresentable { get }
}

extension Engine {
    class DataSource: @unchecked Sendable {
        struct Root: EngineViewPresenterReadable {
            let _presenter: CollectionPresentable
            var presenter: ViewPresentable { _presenter }
            var typePresenter: CollectionPresentable { _presenter }
            init(presenter: CollectionPresentable) {
                self._presenter = presenter
            }
        }
        
        struct Item: EngineViewPresenterReadable {
            let _presenter: CollectionItemPresentable
            var presenter: ViewPresentable { _presenter }
            var typePresenter: CollectionItemPresentable { _presenter }
            init(presenter: CollectionItemPresentable) {
                self._presenter = presenter
            }
        }
        
        struct Section: EngineViewPresenterReadable {
            let _presenter: CollectionSectionPresentable
            var presenter: ViewPresentable { _presenter }
            var typePresenter: CollectionSectionPresentable { _presenter }
            
            let items: [Item]
            let supplementaries: [String: [Item]]
            
            func areSupplementariesEquals(_ other: Section) -> Bool {
                guard self.supplementaries.count == other.supplementaries.count else {
                    return false
                }
                return self.supplementaries.elementsEqual(other.supplementaries, by: {
                    $0.value.elementsEqual($1.value) {
                        $0.presenter === $1.presenter
                    }
                })
            }
            
            init(presenter: CollectionSectionPresentable, items: [Item], supplementaries: [String : [Item]]) {
                self._presenter = presenter
                self.items = items
                self.supplementaries = supplementaries
            }
        }
        
        init(root: CollectionPresentable) {
            self._root = Root(presenter: root)
        }
        
        private var _root: Root
        var sections: [Section] = []
        
    }
}

extension Engine.DataSource {
    func root<T>() -> T? {
        return _root.presenter as? T
    }
    
    var indexes: [(String, IndexPath)]? {
        nil
    }
    
    func indexTitles() -> [String]? {
        nil
    }
    func indexPath(at index: Int) -> IndexPath {
        IndexPath()
    }
    
    func sectionCount() -> Int {
        sections.count
    }
    
    func itemCount(at section: Int) -> Int {
        sections[section].items.count
    }
    
    func item<T>(at indexPath: IndexPath) -> T? {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        return item.presenter as? T
    }
    
    func section<T>(at index: Int) -> T? {
        let section = sections[index]
        return section.presenter as? T
    }
    
    func supplementary<T>(for kind: String, at indexPath: IndexPath) -> T? {
        let section = sections[indexPath.section]
        let supplies = section.supplementaries[kind]
        return supplies?[indexPath.item].presenter as? T
    }
//        func supplementaryPresenter<T>(for kind: String, at index: IndexPath) -> (AnyViewPresenter, T?)? {
//            return nil
//        }
    
    func moveItem(at: IndexPath, to: IndexPath) {}
    
    @MainActor
    public func sectionIndex(for presenter: CollectionSectionPresentable) -> Int? {
        if let section = presenter.superPresenter as? UICollectionSectionPresentable {
            var i = 0
            for sourceSection in sections {
                if sourceSection.presenter == section {
                    return i
                }
                i += 1
            }
        }
        return nil
    }
    
    @MainActor
    public func indexPath(forItem presenter: CollectionItemPresentable) -> IndexPath? {
        if let section = presenter.superPresenter as? CollectionSectionPresentable {
            var i = 0
            for sourceSection in sections {
                if sourceSection.presenter == section {
                    var j = 0
                    for sourceItem in sourceSection.items {
                        if sourceItem.presenter == presenter {
                            return IndexPath(item: j, section: i)
                        }
                        j += 1
                    }
                }
                i += 1
            }
        }
        return nil
    }
    
    @MainActor
    public func indexPath(forSupplementary presenter: CollectionItemPresentable) -> (String, IndexPath)? {
        if let section = presenter.superPresenter as? CollectionSectionPresentable {
            var i = 0
            for sourceSection in sections {
                if sourceSection.presenter == section {
                    for (kind, sourceItems) in sourceSection.supplementaries {
                        var j = 0
                        for sourceItem in sourceItems {
                            if sourceItem.presenter == presenter {
                                return (kind, IndexPath(item: j, section: i))
                            }
                            j += 1
                        }
                    }
                }
                i += 1
            }
        }
        return nil
    }
}
