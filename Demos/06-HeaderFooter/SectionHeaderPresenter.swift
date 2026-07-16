import UIKit
import DDComponent

final class SectionHeaderPresenter: UICollectionViewReusablePresenter<SectionHeaderView> {
    var title: String = "" { didSet { setState {} } }
    var isCollapsed: Bool = false { didSet { setState {} } }
    var onTap: (() -> Void)?

    override func onBindView(_ view: SectionHeaderView) {
        super.onBindView(view)
        view.onTap = { [weak self] in self?.onTap?() }
    }

    override func onUpdate(view: SectionHeaderView, context: ViewUpdateContext) {
        view.title = title; view.isCollapsed = isCollapsed
    }
}
