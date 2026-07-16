import UIKit
import DDComponent

/// Demonstrates autoBindView: child presenters find their views automatically via BFS.
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
        ✅ Root binds one view — top-level AutoBindView
        ✅ Children auto-discover subviews via BFS
        ✅ Shadow presenter shares parent's view
        """
    }
}

final class TopPresenter: ViewPresenter<AutoBindChildViewable> {
    override func onUpdate(view: AutoBindChildViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Top (auto-bound)"
        view.sectionLabel.textColor = .systemRed
    }
}
final class MiddlePresenter: ViewPresenter<AutoBindChildViewable> {
    override func onUpdate(view: AutoBindChildViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Middle (auto-bound)"
        view.sectionLabel.textColor = .systemGreen
    }
}
