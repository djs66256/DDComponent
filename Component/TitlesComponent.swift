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

class TitleModel {
    let title: String
    let controllerClass: UIViewController.Type?
    init(title:String, controllerClass:UIViewController.Type?) {
        self.title = title
        self.controllerClass = controllerClass
    }
}

class TitlesComponent: DDCollectionViewHeaderFooterSectionComponent {
    var cellModels: [TitleModel] = []
    weak var navigationController: UINavigationController?
    
    override init() {
        super.init()
        self.size = CGSize(width: DDComponentAutomaticDimension, height: 60)
        self.itemSpacing = 5
        self.lineSpacing = 5
        self.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15)
    }
    
    override func prepareCollectionView() {
        super.prepareCollectionView()
        self.collectionView?.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TitleCollectionViewCell.self))
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TitleCollectionViewCell.self), for: indexPath) as? TitleCollectionViewCell
        cell?.titleLabel.text = self.cellModels[indexPath.item].title
        cell?.backgroundColor = UIColor.lightGray
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cls = self.cellModels[indexPath.item].controllerClass {
            self.navigationController?.pushViewController(cls.init(), animated: true)
        }
    }
}
