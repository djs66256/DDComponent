//
//  Page1ViewController.swift
//  DDComponent_Example
//
//  Created by daniel on 2022/8/31.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import DDComponent

protocol Page1DataLoader {
    func loadData(_ completion: (Page1Model?, Error?)->Void)
}

class MockPage1DataLoaderImpl: Page1DataLoader {
    func loadData(_ completion: (Page1Model?, Error?) -> Void) {
        completion(Page1Model.mock1(), nil)
    }
}

class Page1ViewController: PageViewController<Page1RootView, Page1RootPresenter, Page1RootPresenterView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.loadData()
    }
    
    override func presenterDidLoad() {
        super.presenterDidLoad()
        
    }
    
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(Page1LikeService.self, { Page1LikeServiceImpl() })
        ServiceInstaller(Page1DataLoader.self, { MockPage1DataLoaderImpl() })
        ServiceInstaller(RouterService.self, { RouterServiceImpl() })
        PresenterInstaller(lazyLoad: false, { ViewPresenter<()>() })
    }
}
