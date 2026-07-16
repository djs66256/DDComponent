import UIKit
import DDComponent

/// Collection item for a card. autoSize = true means the framework calculates size from constraints.
final class CardItemPresenter: CollectionItemPresenter<CardCell>, UICollectionItemFlowPresentable {
    var layoutInfo = UICollectionItemFlowLayoutInfo()
    var card: CardData? { didSet { setState {} } }

    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }

    override func onUpdate(view: CardCell, context: ViewUpdateContext) {
        if let c = card { view.configure(c) }
    }
}
