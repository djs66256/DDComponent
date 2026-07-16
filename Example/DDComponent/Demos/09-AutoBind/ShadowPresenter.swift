import UIKit
import DDComponent

/// Shadow Presenter: a child presenter whose parent owns a UIView.
/// Instead of the parent manually calling `bindView()`, the shadow child
/// auto-discovers a matching subview via BFS by its distinct View type.
///
/// Key point: Shadow uses `BottomSectionViewable` — a different type than
/// TopPresenter and MiddlePresenter. autoBind relies on Swift type matching
/// (`view as? T`), so each presenter needs a unique protocol.
final class ShadowPresenter: ViewPresenter<BottomSectionViewable> {
    private var log: String = "" { didSet { setState {} } }

    override func onBindView(_ view: BottomSectionViewable) {
        super.onBindView(view)
        // This presenter auto-binds to a subview of the parent's view.
        // No manual bindView call needed — autoBindView = true (default) handles it.
        log = "Shadow: auto-bound via BFS ✓"
    }

    override func onUpdate(view: BottomSectionViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Shadow Presenter\n(uses parent's view)"
        view.sectionLabel.textColor = .systemPurple
    }
}
