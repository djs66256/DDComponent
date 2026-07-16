import UIKit
import DDComponent

/// Section header presenter using UICollectionViewFlowItemPresenter — compatible with section.header = ...
final class SectionHeaderPresenter: UICollectionViewFlowItemPresenter<SectionHeaderView> {
    var title: String = "" { didSet { setState {} } }
    var isCollapsed: Bool = false { didSet { setState {} } }
    var onTap: (() -> Void)?

    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }

    override func onBindView(_ view: SectionHeaderView) {
        super.onBindView(view)
        view.onTap = { [weak self] in self?.onTap?() }
    }

    override func onUpdate(view: SectionHeaderView, context: ViewUpdateContext) {
        view.title = title; view.isCollapsed = isCollapsed
    }

    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 44)
    }
}
