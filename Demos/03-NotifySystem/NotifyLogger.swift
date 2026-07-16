import UIKit
import DDComponent

// Listener protocols — one per notify scope
protocol GlobalNotifyListener: AnyObject {
    func onGlobalNotify(message: String)
}
protocol ChildrenNotifyListener: AnyObject {
    func onChildrenNotify(message: String)
}
protocol ParentsNotifyListener: AnyObject {
    func onParentsNotify(message: String)
}
protocol ReusableNotifyListener: AnyObject {
    func onReusableNotify(message: String)
}

/// Logs ALL notification types. Registered as listener for all 4 scopes.
final class NotifyLogger: ViewPresenter<NotifyLoggerViewable> {
    private var messages: [String] = [] { didSet { setState {} } }
    private var flashColor: UIColor = .clear { didSet { setState {} } }

    override func onUpdate(view: NotifyLoggerViewable, context: ViewUpdateContext) {
        view.logText = messages.suffix(20).joined(separator: "\n")
        view.highlightColor = flashColor
        if flashColor != .clear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.setState { self?.flashColor = .clear }
            }
        }
    }

    private func log(_ scope: String, _ msg: String) {
        messages.append("[\(scope)] \(msg)")
        print("[Notify] [\(scope)] \(msg)")
    }
}

protocol NotifyLoggerViewable: AnyObject {
    var logText: String { get set }
    var highlightColor: UIColor { get set }
}

extension NotifyLogger: GlobalNotifyListener {
    func onGlobalNotify(message: String) { log("Global", message); flashColor = .systemRed.withAlphaComponent(0.15) }
}
extension NotifyLogger: ChildrenNotifyListener {
    func onChildrenNotify(message: String) { log("Children", message); flashColor = .systemBlue.withAlphaComponent(0.15) }
}
extension NotifyLogger: ParentsNotifyListener {
    func onParentsNotify(message: String) { log("Parents", message); flashColor = .systemGreen.withAlphaComponent(0.15) }
}
extension NotifyLogger: ReusableNotifyListener {
    func onReusableNotify(message: String) { log("Reusable", message); flashColor = .systemOrange.withAlphaComponent(0.15) }
}
