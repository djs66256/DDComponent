import UIKit
import DDComponent

/// Demonstrates 4 different ViewUpdateContext configurations.
final class AnimationRootPresenter: RootViewPresenter<AnimationViewable> {
    private var offset: CGFloat = 120
    private var squareSize: CGFloat = 80
    private var squareColor: UIColor = .systemBlue

    override func onBindView(_ view: AnimationViewable) {
        super.onBindView(view)
        view.moveBtn.addTarget(self, action: #selector(onMove), for: .touchUpInside)
        view.resizeBtn.addTarget(self, action: #selector(onResize), for: .touchUpInside)
        view.colorBtn.addTarget(self, action: #selector(onColor), for: .touchUpInside)
        view.layoutBtn.addTarget(self, action: #selector(onExpand), for: .touchUpInside)
    }

    override func onUpdate(view: AnimationViewable, context: ViewUpdateContext) {
        view.square.backgroundColor = squareColor
        if context.invalidateLayout {
            view.square.snp.updateConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(offset)
                make.width.height.equalTo(squareSize)
            }
        }
    }

    @objc private func onMove() {
        offset = offset == 120 ? 220 : 120
        setState {} context: {
            $0.animated = true          // default UIView animation
            $0.invalidateLayout = true
        }
    }

    @objc private func onResize() {
        squareSize = squareSize == 80 ? 150 : 80
        setState {} context: {
            $0.invalidateLayout = true
            $0.animator = BounceAnimator()   // custom spring animation
        }
    }

    @objc private func onColor() {
        squareColor = squareColor == .systemBlue ? .systemPink : .systemBlue
        setState {} context: {
            $0.forceDisableAnimation = true  // no animation
        }
    }

    @objc private func onExpand() {
        squareSize = squareSize == 80 ? 200 : 80
        setState {} context: {
            $0.invalidateLayout = true
            // No animated/animator set → synchronous update
        }
    }
}
