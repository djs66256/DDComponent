import UIKit
import DDComponent

/// Shadow Presenter: doesn't bind its own view. Instead, it uses BFS to find
/// a view from the parent presenter's view hierarchy. This lets a presenter
/// control a subview without the parent explicitly handing it over.
final class ShadowPresenter: ViewPresenter<AutoBindChildViewable> {
    private var log: String = "" { didSet { setState {} } }

    override func onBindView(_ view: AutoBindChildViewable) {
        super.onBindView(view)
        // This presenter auto-binds to a subview of the parent's view.
        // No manual bindView call needed — autoBindView = true (default) handles it.
        log = "Shadow: auto-bound via BFS ✓"
    }

    override func onUpdate(view: AutoBindChildViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Shadow Presenter\n(uses parent's view)"
        view.sectionLabel.textColor = .systemPurple
    }
}
