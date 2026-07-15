//
//  CollectionStaticViewController.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/9/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import DDComponent

class CollectionSectionFlowPresenter: CollectionSectionPresenter, UICollectionViewFlowSectionPresentable {
    var layoutInfo = UICollectionViewFlowSectionLayoutInfo()
    
    override init() {
        super.init()
        layoutInfo.itemSpacing = 10
        layoutInfo.lineSpacing = 10
        layoutInfo.inset = .init(top: 0, left: 10, bottom: 0, right: 10)
    }
}

class CollectionStaticViewController: UICollectionFlowPageViewController {
    
    let image = CollectionImageCellPresenter()
    let image2 = CollectionImageCellPresenter()
    let text = CollectionTextViewCellPresenter()
    let text2 = CollectionTextViewCellPresenter()
    
    static let text1 = """
    Currently IM module mostly use MVC, with some screens have a few thousand lines of code, and that causes us some serious problems:
    - Testability: it's very hard to test a class when it mixes UI logic, presentation logic and business logic.
    - Maintainability and Scalability: massive UIViewController makes it very hard to maintain and modify.

    Occasionally, to mitigate the situation, we employ a few solutions:
    - Subclassing: usually it's good when it's an idea, and at the early beginning stage, but over time, new requirements come in which make the subclassing idea not fit anymore, people start to add patch and hack to customise the behaviour of subclass.
    - Break UIViewController into 1 main file and other category files: this can reduce the size of 1 file and make it more managable, but it also means we must expose a lot of private functions/properties in the main file to make it accessible in category files
    - Take smaller part into Interactors: this is quite confusing because we are mixing VIPER and MVC, and the interactors also handle the UI, whereas VIPER interactors are pure business logic.
    """
    static let text2 = """
        Goal
        To decide the architecture to use in IM module to solve all the issues above.
        The architecture should have the following
        1. Testability
        - Be able to test the existing logic of the screen, whether it's presentation logic or business logic
        - [Future] To make it easy to write Snapshot
        2. Simplicity
        - The architecture should be simple and easy to follow, not just for IM team, but for people from other teams when contributing to IM module
        3. Maintainanility & Scalability
        - The architecture must have clear separation of components to make it easier to maintain and modify
        """
    
    let section = CollectionSectionFlowPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "switch", style: .plain, target: self, action: #selector(toggle))
       
        toggle()
        text2.setText(Self.text2)
        
//        section.items = [image, text]
        section.setItems([image, text, image2, text2]) { [weak text2] in
            text2?.scrollToVisible(animated: false)
        }
        presenter.sections = [
            section
        ]
        

    }
    
    var toggleFlag: Bool = false
    
    @objc
    func toggle() {
        toggleFlag = !toggleFlag
        text.setText(toggleFlag ? Self.text1 : Self.text2)
        
        section.setItems(toggleFlag ? [image, image2, text] : [text, image2, image], animated: true)
    }
}
