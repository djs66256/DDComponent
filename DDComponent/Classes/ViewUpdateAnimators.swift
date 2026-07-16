//
//  ViewUpdateAnimators.swift
//  DDComponent
//
//  Created by daniel on 2024/5/30.
//

import Foundation
import UIKit

// MARK: - SpringAnimator

/// A spring-based `ViewUpdateAnimator` powered by `UIView.animate(usingSpringWithDamping:...)`.
///
/// ```swift
/// // Preset
/// setState {} context: {
///     $0.animated = true
///     $0.animator = SpringAnimator.bouncy
/// }
///
/// // Custom
/// setState {} context: {
///     $0.animated = true
///     $0.animator = SpringAnimator(duration: 0.7, damping: 0.5, velocity: 1.0)
/// }
/// ```
public struct SpringAnimator: ViewUpdateAnimator {

    public var duration: TimeInterval
    public var damping: CGFloat
    public var velocity: CGFloat
    public var options: UIView.AnimationOptions

    public init(
        duration: TimeInterval,
        damping: CGFloat,
        velocity: CGFloat,
        options: UIView.AnimationOptions = [.allowUserInteraction]
    ) {
        self.duration = duration
        self.damping = damping
        self.velocity = velocity
        self.options = options
    }

    public func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: options,
            animations: updater
        )
    }

    // MARK: Presets

    /// Duration 0.5, damping 0.7, velocity 0 — general-purpose spring.
    public static let `default` = SpringAnimator(duration: 0.5, damping: 0.7, velocity: 0)

    /// Duration 0.6, damping 0.4, velocity 0.8 — playful bounce.
    public static let bouncy = SpringAnimator(duration: 0.6, damping: 0.4, velocity: 0.8)

    /// Duration 0.8, damping 0.8, velocity 0.3 — gentle, subtle spring.
    public static let gentle = SpringAnimator(duration: 0.8, damping: 0.8, velocity: 0.3)

    /// Duration 0.35, damping 0.65, velocity 0 — quick, iOS-style spring.
    public static let snappy = SpringAnimator(duration: 0.35, damping: 0.65, velocity: 0)
}

// MARK: - EaseAnimator

/// A standard curve `ViewUpdateAnimator` powered by `UIView.animate(withDuration:...)`.
///
/// ```swift
/// // Preset
/// setState {} context: {
///     $0.animated = true
///     $0.animator = EaseAnimator.quick
/// }
///
/// // Custom
/// setState {} context: {
///     $0.animated = true
///     $0.animator = EaseAnimator(duration: 0.5, delay: 0.1, options: [.curveEaseOut])
/// }
/// ```
public struct EaseAnimator: ViewUpdateAnimator {

    public var duration: TimeInterval
    public var delay: TimeInterval
    public var options: UIView.AnimationOptions

    public init(
        duration: TimeInterval,
        delay: TimeInterval = 0,
        options: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseInOut]
    ) {
        self.duration = duration
        self.delay = delay
        self.options = options
    }

    public func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: options,
            animations: updater
        )
    }

    // MARK: Presets

    /// Duration 0.3, `.curveEaseInOut` — matches the framework default.
    public static let `default` = EaseAnimator(duration: 0.3, options: [.allowUserInteraction, .curveEaseInOut])

    /// Duration 0.15, `.curveEaseInOut` — micro-interactions.
    public static let quick = EaseAnimator(duration: 0.15, options: [.allowUserInteraction, .curveEaseInOut])

    /// Duration 0.8, `.curveEaseInOut` — deliberate, slow transitions.
    public static let slow = EaseAnimator(duration: 0.8, options: [.allowUserInteraction, .curveEaseInOut])

    /// Duration 0.3, `.curveEaseIn`.
    public static let easeIn = EaseAnimator(duration: 0.3, options: [.allowUserInteraction, .curveEaseIn])

    /// Duration 0.3, `.curveEaseOut`.
    public static let easeOut = EaseAnimator(duration: 0.3, options: [.allowUserInteraction, .curveEaseOut])
}
