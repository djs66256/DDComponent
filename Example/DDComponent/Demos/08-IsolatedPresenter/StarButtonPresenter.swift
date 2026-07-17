import UIKit
import DDComponent

final class StarButtonPresenter: ViewPresenter<StarButtonViewable> {
    private var isStarred: Bool = false { didSet { setState {} } }

    override func onBindView(_ view: StarButtonViewable) {
        super.onBindView(view)
        view.onTap = { [weak self] in
            self?.setState { self?.isStarred = !(self?.isStarred ?? false) }
        }
    }

    override func onUpdate(view: StarButtonViewable, context: ViewUpdateContext) {
        view.isStarred = isStarred
    }
}
