import UIKit
import DDComponent

/// Demonstrates autoBindView: child presenters find their views automatically via BFS.
///
/// How autoBind works:
/// - BFS walks the parent's UIView subviews and does `view as? T`
/// - `T` is each child presenter's generic View type (e.g., `TopSectionViewable`)
/// - So each child MUST use a **distinct** View protocol so BFS can distinguish them
///
/// In this demo:
/// - TopPresenter<V: TopSectionViewable> → BFS finds the first `TopSectionViewable` subview
/// - MiddlePresenter<V: MiddleSectionViewable> → BFS finds the first `MiddleSectionViewable` subview
/// - ShadowPresenter<V: BottomSectionViewable> → BFS finds the first `BottomSectionViewable` subview
///
/// Without distinct types, all presenters would bind to the same first-matching subview.
final class AutoBindRootPresenter: RootViewPresenter<AutoBindRootViewable> {

    required init() {
        super.init()
        // autoBindChildrenPresenterViews: when root binds its view,
        // children automatically search for matching subviews.
        autoBindChildrenPresenterViews = true

        typeBox(TopPresenter())
        typeBox(MiddlePresenter())
        typeBox(ShadowPresenter())
    }

    override func onBindView(_ view: AutoBindRootViewable) {
        super.onBindView(view)
        // Only root view is explicitly bound. Children auto-discover via BFS.

        view.statusLabel.text = """
        ✅ autoBind matches by View TYPE (protocol)
        ✅ Each presenter uses a distinct View protocol
        ✅ BFS finds first subview matching `view as? T`
        ✅ Bottom uses Shadow pattern (shares parent's UIView)
        """
    }
}

// Each presenter uses a DISTINCT View protocol so autoBind BFS can tell them apart.
// All presenters look the same from a code perspective, but their generic View type differs.

final class TopPresenter: ViewPresenter<TopSectionViewable> {
    override func onUpdate(view: TopSectionViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Top (auto-bound)"
        view.sectionLabel.textColor = .systemRed
    }
}
final class MiddlePresenter: ViewPresenter<MiddleSectionViewable> {
    override func onUpdate(view: MiddleSectionViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Middle (auto-bound)"
        view.sectionLabel.textColor = .systemGreen
    }
}
