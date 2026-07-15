//
//  OldViewUpdatePipeline.swift
//  DDComponent
//
//  Created by daniel on 2024/1/7.
//

import Foundation

@MainActor
open class BaseViewUpdatePipeline: ViewUpdatePipeline {
    struct UpdateInfo {
        var presenter: ViewPresentable
        var context: ViewUpdateContext
        var completions: [() -> Void] = []
    }
    
    struct UpdateKey: Hashable {
        var presenter: ViewPresentable
        
        var hashValue: Int { presenter.hashValue }
        func hash(into hasher: inout Hasher) {
            presenter.hash(into: &hasher)
        }
        static func == (lhs: BaseViewUpdatePipeline.UpdateKey, rhs: BaseViewUpdatePipeline.UpdateKey) -> Bool {
            lhs.presenter == rhs.presenter
        }
    }
    
    public weak var superPipeline: ViewUpdatePipeline?
    public var rootView: UIView?
    public weak var rootPresenter: ViewPresentable?
    
    init(presenter: ViewPresentable, view: UIView? = nil) {
        self.rootPresenter = presenter
        self.rootView = view
    }
    
    public func destroy() {
        isDestroyed = true
    }
    
    public var isDirty = false
    var isDestroyed = false
    public var isAnimated = true
    public var forceDisableAnimation = false
    public var layoutImmediately = false
    var invalidateDataSource: Bool = false
    var invalidateContentSize: Bool = false
    var updateInfos: [UpdateKey: UpdateInfo] = [:]
    
    open func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        guard !isDestroyed else { return }
        
        // Binding view should not update asynchronize, just call update immediately.
        if context.isBindingView {
            presenter.updateView(context: context)
        }
        
        isAnimated = isAnimated && context.animated
        layoutImmediately = layoutImmediately || context.layoutImmediately
        forceDisableAnimation = forceDisableAnimation || context.forceDisableAnimation
        invalidateDataSource = invalidateDataSource || context.invalidateDataSource
        invalidateContentSize = invalidateContentSize || context.invalidateContentSize
        
        // When collection view in another collection cell, child cell size changed needs notify
        // super collection cell to recaculate layout
        var resizeSuperPresenter: (() -> Void)? = nil
        if context.invalidateSuperPresenterContentSize && !context.isDryRun,
           let superPipeline,
           let superPresenter = presenter.superPresenter {
            let animated = isAnimated
            resizeSuperPresenter = { [weak superPipeline] in
                guard let superPipeline else { return }
                var superContext = ViewUpdateContext()
                superContext.invalidateContentSize = true
                superContext.animated = animated
                superContext.invalidateSuperPresenterContentSize = true
                superPipeline.markDirty(presenter: superPresenter, context: superContext, nil)
            }
        }
        
        let key = UpdateKey(presenter: presenter)
        if var info = updateInfos[key] {
            info.context.merge(context)
            if let completion = completion {
                info.completions.append(completion)
            }
            if let resizeSuperPresenter {
                info.completions.append(resizeSuperPresenter)
            }
            updateInfos[key] = info
        }
        else {
            var info = UpdateInfo(presenter: presenter, context: context)
            if let completion = completion {
                info.completions.append(completion)
            }
            if let resizeSuperPresenter {
                info.completions.append(resizeSuperPresenter)
            }
            updateInfos[key] = info
        }
        
        dispatchNeedsUpdateView()
    }
    
    open func dispatchNeedsUpdateView() {
        if !isDirty {
            isDirty = true
            DispatchQueue.main.async {
                self.updateViewIfNeeded(synchronize: false)
            }
        }
    }
    
    open func updateViewIfNeeded(synchronize: Bool) {
        assert(Thread.isMainThread, "Update UI MUST on main thread!")
        
        guard !isDestroyed else { return }
        guard isDirty else { return }
        
        var updateInfos: [UpdateKey: UpdateInfo]!
        invokeUpdateView(synchronize: synchronize) {
            // Cache update infos for complete usage
            updateInfos = self.updateInfos
            self.doUpdate(updateInfos: updateInfos)
            // After updating, remove all update infos, avoid new update may add to it.
            self.updateInfos.removeAll()
        } completion: {
            self.doCompletion(updateInfos: updateInfos)
        }
        
        isDirty = false
    }
    
    public func updateViewPresenterIfNeeded(_ presenter: ViewPresentable) {
        let key = UpdateKey(presenter: presenter)
        if let info = updateInfos[key] {
            let ctx = info.context
            // If data source changed, we still update all views.
            if invalidateDataSource || invalidateContentSize || ctx.invalidateLayout {
                updateViewIfNeeded(synchronize: true)
            }
            else {
                info.presenter.updateView(context: info.context)
                for completion in info.completions {
                    completion()
                }
                updateInfos.removeValue(forKey: key)
            }
        }
    }
    
    open func invokeUpdateView(synchronize: Bool, _ updater: @escaping ()->Void, completion: @escaping ()->Void) {
        updater()
        completion()
    }
    
    open func invokeWithAnimation(_ updater: @escaping ()->Void, completion: @escaping ()->Void) {
        UIView.animate(withDuration: 0.3) {
            updater()
        } completion: { _Arg in
            completion()
        }
    }
    
    open func invokeWithoutAnimation(_ updater: @escaping ()->Void, completion: @escaping ()->Void) {
        let enabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()
        let disabled = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        
        updater()
        
        CATransaction.commit()
        
        UIView.setAnimationsEnabled(enabled)
        CATransaction.setDisableActions(disabled)
        
        completion()
    }
    
    func doUpdate(updateInfos: [UpdateKey: UpdateInfo]) {
        for (_, info) in updateInfos {
            info.presenter.updateView(context: info.context)
        }
        forceDisableAnimation = false
        invalidateDataSource = false
        invalidateContentSize = false
        layoutImmediately = false
    }
    
    func doCompletion(updateInfos: [UpdateKey: UpdateInfo]) {
        isAnimated = true
        for (_, info) in updateInfos {
            for completion in info.completions {
                completion()
            }
        }
    }
}

open class DefaultViewUpdatePipeline: BaseViewUpdatePipeline {
    override open func invokeUpdateView(synchronize: Bool, _ updater: @escaping ()->Void, completion: @escaping ()->Void) {
        if forceDisableAnimation {
            invokeWithoutAnimation({
                updater()
                self.rootView?.layoutIfNeeded()
            }, completion: completion)
        }
        else if isAnimated {
            invokeWithAnimation({
                updater()
                self.rootView?.layoutIfNeeded()
            }, completion: completion)
        }
        else {
            super.invokeUpdateView(synchronize: synchronize, updater, completion:completion)
        }
    }
}

open class DryRunViewUpdatePipeline: DefaultViewUpdatePipeline {
    
    open override func markDirty(presenter: ViewPresentable, context: ViewUpdateContext, _ completion: (() -> Void)?) {
        var context = context
        context.isDryRun = true
        context.layoutImmediately = true
        presenter.updateView(context: context)
        completion?()
    }
}
