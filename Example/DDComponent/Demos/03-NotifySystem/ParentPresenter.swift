import UIKit
import DDComponent

final class ParentPresenter: ViewPresenter<NotifyZoneViewable> {
    private let name: String
    init(name: String) { self.name = name; super.init() }

    override func onBindView(_ view: NotifyZoneViewable) {
        super.onBindView(view)
        view.zoneTitle = name
        view.zoneColor = .systemBlue.withAlphaComponent(0.1)
        view.onTap = { [weak self] in
            // notifyChildren: message flows DOWN to all descendants
            self?.notify(listener: ChildrenNotifyListener.self, scope: .children) {
                $0.onChildrenNotify(message: "from \(self?.name ?? "")")
            }
        }
    }
}

extension ParentPresenter: ParentsNotifyListener {
    func onParentsNotify(message: String) {
        print("[Notify] \(name) received Parents notify: \(message)")
    }
}
