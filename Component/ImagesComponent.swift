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

private let imageSize = CGSize(width: 80, height: 80)

class ImageModel {
    let imageName: String
    let controllerClass: UIViewController.Type?
    
    private var _image: UIImage?
    
    var image: UIImage? {
        get {
            if _image == nil {
                let scanner = Scanner(string: self.imageName)
                var i: UInt64 = 0
                scanner.scanHexInt64(&i)
                let color = UIColor(red: CGFloat((i>>16)&0xff) / 255.0,
                                    green: CGFloat((i>>8)&0xff) / 255.0,
                                    blue: CGFloat(i&0xff) / 255.0,
                                    alpha: 1)
                UIGraphicsBeginImageContext(imageSize)
                color.setFill()
                UIBezierPath(rect: CGRect(origin: .zero, size: imageSize)).fill()
                _image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            return _image
        }
    }
    
    init(imageName: String, controllerClass: UIViewController.Type?) {
        self.imageName = imageName
        self.controllerClass = controllerClass
    }
}

class ImagesComponent: DDCollectionViewHeaderFooterSectionComponent {
    var images : [ImageModel] = []
    weak var navigationController: UINavigationController?
    
    override init() {
        super.init()
        self.size = imageSize
        self.lineSpacing = 5
        self.itemSpacing = 5
    }
    
    override func prepareCollectionView() {
        super.prepareCollectionView()
        self.collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self))
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self), for: indexPath) as? ImageCollectionViewCell
        cell?.imageView.image = self.images[indexPath.item].image
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cls = self.images[indexPath.item].controllerClass {
            self.navigationController?.pushViewController(cls.init(), animated: true)
        }
    }
}
