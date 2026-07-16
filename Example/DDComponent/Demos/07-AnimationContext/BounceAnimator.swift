import UIKit
import DDComponent

/// Demo: using built-in framework animators.
///
/// Instead of defining custom animator classes, use the framework-provided presets:
///
/// ```swift
/// // Spring bounce
/// $0.animator = SpringAnimator.bouncy
///
/// // Slow ease-in-out
/// $0.animator = EaseAnimator.slow
///
/// // Or customize parameters:
/// $0.animator = SpringAnimator(duration: 0.7, damping: 0.5, velocity: 1.0)
/// $0.animator = EaseAnimator(duration: 0.5, delay: 0.1, options: [.curveEaseOut])
/// ```
