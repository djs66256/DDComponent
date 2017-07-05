import UIKit
import DDComponent

public class TitleModel {
    public let title: String
    public init(title:String) {
        self.title = title
    }
}

public class TitlesComponent: DDCollectionViewHeaderFooterSectionComponent {
    public var cellModels: [TitleModel] = []
    
    override public init() {
        super.init()
        self.size = CGSize(width: DDComponentAutomaticDimension, height: 60)
        self.itemSpacing = 5
        self.lineSpacing = 5
        self.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15)
    }
    
    override public func prepareCollectionView() {
        super.prepareCollectionView()
        self.collectionView?.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TitleCollectionViewCell.self))
    }
    
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
    }
}

//
// Header
public class TextCollectionReusableView: UICollectionReusableView {
    lazy public var textLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        return label
    }()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel.frame = self.bounds
    }
}

public class HeaderComponent: DDCollectionViewSectionComponent {
    
    public var text: String?
    
    override public init() {
        super.init()
        self.headerSize = CGSize(width: DDComponentAutomaticDimension, height: 50)
    }
    
    override public func prepareCollectionView() {
        super.prepareCollectionView()
        
        self.collectionView?.register(TextCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(TextCollectionReusableView.self))
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let textView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(TextCollectionReusableView.self), for: indexPath) as? TextCollectionReusableView
        textView?.textLabel.textAlignment = .left
        textView?.textLabel.font = UIFont.boldSystemFont(ofSize: 17)
        textView?.textLabel.text = self.text
        textView?.backgroundColor = UIColor.orange
        return textView!
    }
    
}
