import UIKit
import DDComponent

/// Demonstrates all 4 NotifyScope types. Zone taps fire different scopes.
final class NotifyRootPresenter: RootViewPresenter<NotifyDemoViewable> {
    let logger = NotifyLogger()
    let parent = ParentPresenter(name: "Parent")
    let child = ChildPresenter(name: "Child")

    override func onAttach() {
        super.onAttach()
        // Register logger as listener for ALL 4 scopes
        add(listener: GlobalNotifyListener.self, object: logger)
        add(listener: ChildrenNotifyListener.self, object: logger)
        add(listener: ParentsNotifyListener.self, object: logger)
        add(listener: ReusableNotifyListener.self, object: logger)
        add(listener: ParentsNotifyListener.self, object: parent)
        add(listener: ChildrenNotifyListener.self, object: child)
        add(child: logger); add(child: parent)
        parent.add(child: child)  // Child is a child of Parent in P-Tree — enables .children ↓ and .parents ↑
    }

    override func onBindView(_ view: NotifyDemoViewable) {
        super.onBindView(view)
        logger.bindView(view.loggerZone)
        parent.bindView(view.parentZone)
        child.bindView(view.childZone)

        // .global: broadcast from root to all listeners
        view.globalZone.onTap = { [weak self] in
            self?.notify(listener: GlobalNotifyListener.self, scope: .global) {
                $0.onGlobalNotify(message: "Broadcast to ALL")
            }
        }
        // .reusable: notify nearest reusable parent (root in this case)
        view.reusableZone.onTap = { [weak self] in
            self?.notify(listener: ReusableNotifyListener.self, scope: .reusable) {
                $0.onReusableNotify(message: "Reusable scope")
            }
        }
    }
}
