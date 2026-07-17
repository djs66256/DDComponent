import UIKit
import DDComponent

/// Demonstrates 4 different animation modes via ViewUpdateContext.
/// Every button press produces a visible animation — no silent/instant changes.
final class AnimationRootPresenter: RootViewPresenter<AnimationViewable> {
    private var offset: CGFloat = 120
    private var squareSize: CGFloat = 80
    private var squareColor: UIColor = .systemBlue
    private var squareTransform: CGAffineTransform = .identity

    override func onBindView(_ view: AnimationViewable) {
        super.onBindView(view)
        view.moveBtn.addTarget(self, action: #selector(onMove), for: .touchUpInside)
        view.resizeBtn.addTarget(self, action: #selector(onResize), for: .touchUpInside)
        view.colorBtn.addTarget(self, action: #selector(onColor), for: .touchUpInside)
        view.layoutBtn.addTarget(self, action: #selector(onExpand), for: .touchUpInside)
    }

    override func onUpdate(view: AnimationViewable, context: ViewUpdateContext) {
        view.square.backgroundColor = squareColor
        view.square.transform = squareTransform
        if context.invalidateLayout, let sv = view.square.superview {
            view.square.snp.updateConstraints { make in
                make.top.equalTo(sv.safeAreaLayoutGuide).offset(offset)
                make.width.height.equalTo(squareSize)
            }
        }
    }

    // MARK: - 1. Default animation (animated = true)
    @objc private func onMove() {
        offset = offset == 120 ? 220 : 120
        squareTransform = offset == 220
            ? CGAffineTransform(rotationAngle: .pi / 6).scaledBy(x: 1.2, y: 1.2)
            : .identity
        setState {} context: {
            $0.animated = true          // default UIView animation
            $0.invalidateLayout = true
        }
    }

    // MARK: - 2. Custom spring bounce animator
    @objc private func onResize() {
        squareSize = squareSize == 80 ? 150 : 80
        setState {} context: {
            $0.invalidateLayout = true
            $0.animated = true            // required: layoutIfNeeded() only runs in animation block when animated=true
            $0.animator = SpringAnimator.bouncy   // takes priority over default 0.3s UIView.animate
        }
    }

    // MARK: - 3. Custom slow ease-in-out animator
    @objc private func onColor() {
        squareColor = squareColor == .systemBlue ? .systemPink : .systemBlue
        squareTransform = squareTransform == .identity
            ? CGAffineTransform(rotationAngle: .pi).scaledBy(x: 0.5, y: 0.5)
            : .identity
        setState {} context: {
            $0.animated = true
            $0.animator = EaseAnimator.slow      // takes priority over default 0.3s, uses 0.8s ease-in-out
        }
    }

    // MARK: - 4. Default animate + layout
    @objc private func onExpand() {
        squareSize = squareSize == 80 ? 200 : 80
        offset = squareSize == 200 ? 140 : 120
        squareColor = squareSize == 200 ? .systemOrange : .systemBlue
        setState {} context: {
            $0.animated = true                // default animation
            $0.invalidateLayout = true
        }
    }
}
