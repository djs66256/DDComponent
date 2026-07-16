import UIKit
import DDComponent

final class ChildPresenter: ViewPresenter<NotifyZoneViewable> {
    private let name: String
    init(name: String) { self.name = name; super.init() }

    override func onBindView(_ view: NotifyZoneViewable) {
        super.onBindView(view)
        view.zoneTitle = name
        view.zoneColor = .systemGray6
        view.onTap = { [weak self] in
            // notifyParents: message flows UP to all ancestors
            self?.notify(listener: ParentsNotifyListener.self, scope: .parents) {
                $0.onParentsNotify(message: "from \(self?.name ?? "")")
            }
        }
    }
}

extension ChildPresenter: ChildrenNotifyListener {
    func onChildrenNotify(message: String) {
        print("[Notify] \(name) received Children notify: \(message)")
    }
}
