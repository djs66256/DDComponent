import UIKit
import DDComponent

/// Simplest presenter: ViewPresenter<View> + setState + lifecycle logging.
///
/// Capabilities: ViewPresenter, setState → onUpdate, full lifecycle log
final class HelloPresenter: ViewPresenter<HelloViewable> {

    private var count: Int = 0 {
        didSet { setState {} }
    }

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        print("[HelloDDComponent] onAttach")
    }

    override func onDetach() {
        super.onDetach()
        print("[HelloDDComponent] onDetach")
    }

    override func onBindView(_ view: HelloViewable) {
        super.onBindView(view)
        print("[HelloDDComponent] onBindView")
        view.incrementButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    override func onUnbindView() {
        super.onUnbindView()
        print("[HelloDDComponent] onUnbindView")
        view?.incrementButton.removeTarget(self, action: nil, for: .allEvents)
    }

    override func onUpdate(view: HelloViewable, context: ViewUpdateContext) {
        print("[HelloDDComponent] onUpdate — count=\(count)")
        view.countLabel.text = "\(count)"
    }

    @objc private func onTap() {
        setState { count += 1 }
    }
}
