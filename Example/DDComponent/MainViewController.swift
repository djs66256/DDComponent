import UIKit
import DDComponent

/// A minimal table row presenter for the main navigation list.
/// Shows how to use `onUpdate` for cell config and `onDidSelect` for tap handling.
final class MainRowItemPresenter: UITableViewItemPresenter<UITableViewCell> {
    var title: String?
    var onTap: (() -> Void)?

    override func onUpdate(view: UITableViewCell, context: ViewUpdateContext) {
        var config = view.defaultContentConfiguration()
        config.text = title
        view.contentConfiguration = config
        view.accessoryType = .disclosureIndicator
    }

    override var shouldSelect: Bool { true }

    override func onDidSelect() {
        onTap?()
    }
}

/// Main navigation page. Uses DDComponent's UITablePageDefaultViewController
/// to render the demo list — the framework demo eats its own dog food.
final class MainViewController: UITablePageDefaultViewController {

    struct DemoEntry {
        let title: String
        let vc: () -> UIViewController
    }

    private let demos: [DemoEntry] = [
        .init(title: "🟢 01  HelloDDComponent", vc: { HelloViewController() }),
        .init(title: "🟢 02  Service & DI", vc: { ServiceDIViewController() }),
        .init(title: "🟢 03  Notify 事件系统", vc: { NotifyViewController() }),
        .init(title: "🟡 04  P-Tree 组合", vc: { PTreeViewController() }),
        .init(title: "🟡 05  列表与部分更新", vc: { ListViewController() }),
        .init(title: "🟡 06  Header/Footer", vc: { HeaderFooterViewController() }),
        .init(title: "🟡 07  动画与 ViewUpdateContext", vc: { AnimationViewController() }),
        .init(title: "🔴 08  IsolatedViewPresenter", vc: { IsolatedViewController() }),
        .init(title: "🔴 09  AutoBind & Shadow", vc: { AutoBindViewController() }),
        .init(title: "🔴 10  综合示例 — Feed", vc: { FeedViewController() }),
        .init(title: "📦     CyclePageView 集成", vc: { CyclePageViewController() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DDComponent Demo"

        let items = demos.map { entry -> MainRowItemPresenter in
            let item = MainRowItemPresenter()
            item.title = entry.title
            item.onTap = { [weak self] in
                let vc = entry.vc()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            return item
        }

        presenter.sections = [
            UITableViewSectionPresenter(items: items)
        ]
    }
}
