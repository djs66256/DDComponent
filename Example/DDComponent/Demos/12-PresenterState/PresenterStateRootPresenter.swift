import UIKit
import DDComponent
import DDComponentMacrosClient

/// Demonstrates @PresenterState macro: eliminates `didSet { setState {} }` boilerplate.
///
/// Compare with the old pattern:
///     private var count: Int = 0 { didSet { setState {} } }
///
/// @PresenterState expands to:
///   - var $count: Int = 0               (backing storage)
///   - var count: Int { get/set }         (computed property, wraps setState)
///   - func setCount(_:context:completion:) (convenience method)
final class PresenterStateRootPresenter: RootViewPresenter<PresenterStateViewable> {

    // MARK: - @PresenterState properties

    /// Simple state: setting count = X automatically calls setState {}.
    @PresenterState
    var count: Int = 0

    required init() {
        super.init()
        autoBindView = true
    }

    override func onBindView(_ view: PresenterStateViewable) {
        super.onBindView(view)
        view.incrementButton.addTarget(self, action: #selector(onIncrement), for: .touchUpInside)
        view.animatedButton.addTarget(self, action: #selector(onAnimatedIncrement), for: .touchUpInside)
        view.resetButton.addTarget(self, action: #selector(onReset), for: .touchUpInside)
    }

    override func onUpdate(view: PresenterStateViewable, context: ViewUpdateContext) {
        view.countLabel.text = "\(count)"
    }

    // MARK: - Actions

    /// Basic usage: assign to property directly — setState is automatic.
    @objc private func onIncrement() {
        count += 1
    }

    /// Context usage: use the generated setCount(_:context:) method.
    @objc private func onAnimatedIncrement() {
        setCount(count + 5) {
            $0.animated = true
            $0.invalidateLayout = true
        }
    }

    @objc private func onReset() {
        count = 0
    }
}
