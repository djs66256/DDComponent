import UIKit
import DDComponent

/// Custom animator: spring-based bounce for lively size changes.
final class BounceAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.6, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: updater
        )
    }
}

/// Custom animator: slow ease-in-out for deliberate pacing.
final class SlowAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: 1.2, delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: updater
        )
    }
}
