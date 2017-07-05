//: # 创建组件
//: 为了使用简单，接口都和`UICollectionDelegate`系统接口保持一致

import DDComponent

public class DemoComponent: DDCollectionViewHeaderFooterSectionComponent {
    public var cellModels: [TitleModel] = []
    
//: 在init中初始化参数
    override public init() {
        super.init()
        self.size = CGSize(width: DDComponentAutomaticDimension, height: 60)
        self.itemSpacing = 5
        self.lineSpacing = 5
        self.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15)
    }
    
//: prepare用来注册cell
    
    override public func prepareCollectionView() {
        super.prepareCollectionView()
        self.collectionView?.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TitleCollectionViewCell.self))
    }
    
//: 其他接口均和系统接口一致
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TitleCollectionViewCell.self), for: indexPath) as? TitleCollectionViewCell
        cell?.titleLabel.text = self.cellModels[indexPath.item].title
        cell?.backgroundColor = UIColor.lightGray
        return cell!
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected at \(indexPath)")
    }
}

//: [Next](@next)
