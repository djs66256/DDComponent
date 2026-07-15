//
//  ViewUpdateContext.swift
//  DDComponent
//
//  Created by daniel on 2022/9/23.
//

import Foundation

@MainActor
public protocol ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void)
}

/// Decide how view will be updated.
public struct ViewUpdateContext {
    
    public var isDryRun: Bool = false
    
    /// Used when first bind view. It will update view directly, because initial state MUST be dirty.
    public var isBindingView: Bool = false
    
    /// If true, update view immediately when `setState`. It will call `onUpdate(view:context:)` immediately.
    public var updateViewImmediately: Bool = false
    
    /// If true, will call `invalidateConstraints()` after update view synchronizely.
    public var invalidateConstraints: Bool = false
    
    /// If true, will call `invalidateLayout()` after update view synchronizely.
    public var invalidateLayout: Bool = false
    
    /// If true, will call `layoutIfNeeded()` after update view synchronizely.
    public var layoutImmediately: Bool = false
    
    /// If true, will update view within an animation block, like `UIView.animate(..., { updateView() })`
    public var animated: Bool = false
    
    /// If true, will force disable animations
    /// like `UIView.setAnimationsEnabled(false); CATransaction.setDisableActions(true)`
    public var forceDisableAnimation: Bool = false
    
    
    // For reusable view, UITableView, UICollectionView etc.
    
    /// DataSource is changed, means we should reload or batchUpdates UICollectionView or UITableView.
    public var invalidateDataSource: Bool = false
    
    /// ContentSize is changed, means we can only update the UICollectionViewLayout, without reload all list.
    /// Also it will clear size cache, and calculate new size when updating.
    public var invalidateContentSize: Bool = false
    
    /// It used when collection view in another collection cell, child cell size changed needs notify
    /// super collection cell to recaculate layout.
    public var invalidateSuperPresenterContentSize: Bool = false
    
    /// Extra infos, can set any info you need to recoginise each different update actions.
    @MainActor public var infos: [AnyHashable: Any] = [:]
    
//    @MainActor public subscript(_ key: String) -> Any? {
//        get { infos[key] }
//        set { infos[key] = newValue }
//    }
    
    @MainActor public subscript<KeyType>(_ key: KeyType.Type) -> KeyType.ValueType
    where KeyType : ViewUpdateContextInfoKey {
        get { infos[ObjectIdentifier(key)] as? KeyType.ValueType ?? KeyType.defaultValue}
        set { infos[ObjectIdentifier(key)] = newValue }
    }
    
    public init() {}
    
    public static var dryRun: ViewUpdateContext {
        var context = ViewUpdateContext()
        context.isDryRun = true
        return context
    }
    
    /// Used when binding view, should update view immediately this time.
    @inlinable mutating func bindView() {
        self.isBindingView = true
    }
    
    @MainActor public mutating func merge(_ context: ViewUpdateContext) {
        isDryRun = isDryRun || context.isDryRun
        updateViewImmediately = updateViewImmediately || context.updateViewImmediately
        invalidateConstraints = invalidateConstraints || context.invalidateConstraints
        invalidateLayout = invalidateLayout || context.invalidateLayout
        layoutImmediately = layoutImmediately || context.layoutImmediately
        animated = animated && context.animated
        forceDisableAnimation = forceDisableAnimation || context.forceDisableAnimation
        invalidateDataSource = invalidateDataSource || context.invalidateDataSource
        invalidateContentSize = invalidateContentSize || context.invalidateContentSize
        invalidateSuperPresenterContentSize = invalidateSuperPresenterContentSize || context.invalidateSuperPresenterContentSize
        infos.merge(context.infos, uniquingKeysWith: { return $1 })
    }
}

public protocol ViewUpdateContextInfoKey {
    associatedtype ValueType
    static var defaultValue: ValueType { get }
}

public extension ViewUpdateContext {
    
    /// Used when update sections or items, should reload data source at this time.
    @inlinable mutating func reloadData() {
        self.invalidateDataSource = true
    }
}

// Animation
public extension ViewUpdateContext {
    private struct AnimatorKey: ViewUpdateContextInfoKey {
        typealias ValueType = ViewUpdateAnimator?
        static var defaultValue: ViewUpdateAnimator? { nil }
    }
    
    @MainActor var animator: ViewUpdateAnimator? {
        set { self[AnimatorKey.self] = newValue }
        get { self[AnimatorKey.self] }
    }
    
    @MainActor func animate(_ updater: @escaping () -> Void) {
        if let animator = self.animator {
            animator.animate(with: self, updater)
        }
        else if self.forceDisableAnimation {
            UIView.performWithoutAnimation(updater)
        }
        else if self.animated {
            UIView.animate(withDuration: 0.3, animations: updater)
        }
        else {
            updater()
        }
    }
}
