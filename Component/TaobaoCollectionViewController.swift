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

class GoodsItem {
    let type: Int
    let title: String?
    init(type: Int, title:String?) {
        self.type = type
        self.title = title
    }
}

class TaobaoCollectionViewController: UICollectionViewController {
    
    lazy var rootComponent: DDCollectionViewRootComponent = {
        let root = DDCollectionViewRootComponent(collectionView: self.collectionView!)
        return root
    }()
    
    lazy var banner: DDCollectionViewBaseComponent = {
        let comp = TaobaoBannerComponent()
        return comp
    }()
    
    lazy var entries: TaobaoEntriesComponent = {
        let comp = TaobaoEntriesComponent()
        return comp
    }()
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .init(rawValue: 0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.collectionView?.backgroundColor = UIColor.darkGray

        self.entries.entries = [
            "天猫", "聚划算", "天猫国际", "外卖", "天猫超市",
            "充值中心", "飞猪旅行", "领金币", "拍卖", "分类"
        ]
        var components = [self.banner, self.entries]
        
        let group = DDCollectionViewSectionGroupComponent()
        group.subComponents = components
        let status = StatusComponent.component(normalComponent: group)
        status.state = .loading
        status.emptySize = CGSize(width: DDComponentAutomaticDimension, height: DDComponentAutomaticDimension)
        
        
        self.rootComponent.subComponents = [status]
        self.collectionView?.reloadData()
        
        // Request ...
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            let goodsData = [
                GoodsItem(type: 0, title: nil),
                GoodsItem(type: 2, title: "Header 2"),
                GoodsItem(type: 3, title: nil),
                GoodsItem(type: 1, title: nil),
                GoodsItem(type: 3, title: nil),
                GoodsItem(type: 2, title: "Header 2"),
                GoodsItem(type: 0, title: nil),
                GoodsItem(type: 2, title: nil),
                GoodsItem(type: 1, title: "Header 1"),
                GoodsItem(type: 0, title: nil),
                GoodsItem(type: 2, title: nil),
                GoodsItem(type: 1, title: nil)
            ]
            for item in goodsData {
                let goods = TaobaoGoodsComponent()
                goods.goodsItem = item
                if let title = item.title {
                    goods.headerComponent = {
                        let header = HeaderComponent()
                        header.text = title
                        return header
                    }()
                }
                components.append(goods)
            }
            group.subComponents = components
            
            status.state = .normal
            self.collectionView?.reloadData()
        }
    }

}
