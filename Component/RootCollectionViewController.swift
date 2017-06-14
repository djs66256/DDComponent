// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import DDComponent

class RootCollectionViewController: UICollectionViewController {

    var rootComponent: DDCollectionViewRootComponent?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rootComponent = DDCollectionViewRootComponent(collectionView: self.collectionView!, bind: true);
        
        let cellComponent = TitlesComponent()
        cellComponent.navigationController = self.navigationController
        cellComponent.cellModels = [
            TitleModel(title: "simple", controllerClass: SimpleViewController.self),
            TitleModel(title: "sections", controllerClass: SectionsViewController.self),
            TitleModel(title: "Header Footer", controllerClass: HeaderFooterViewController.self),
            TitleModel(title: "Status", controllerClass: StatusViewController.self),
            TitleModel(title: "Header Footer Status", controllerClass: HeaderStatusViewController.self),
            TitleModel(title: "Tao Bao Example 淘宝首页例子", controllerClass: TaobaoCollectionViewController.self)
        ]
        
        rootComponent?.subComponents = [cellComponent]
        self.collectionView?.reloadData()
    }

}
