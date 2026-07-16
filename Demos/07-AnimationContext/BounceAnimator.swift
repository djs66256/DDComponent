import UIKit
import DDComponent

/// Custom animator: spring-based bounce for lively size changes.
final class BounceAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.5, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: updater
        )
    }
}
