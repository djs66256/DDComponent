import UIKit
import DDComponent

/// A minimal table row presenter for the main navigation list.
/// Shows how to use `onUpdate` for cell config and `onDidSelect` for tap handling.
final class MainRowItemPresenter: UITableViewItemPresenter<UITableViewCell> {
    var title: String?
    var onTap: (() -> Void)?

    override init() {
        super.init()
        shouldHighlight = true
        layoutInfo.calculateSizeAutomatically = false
    }

    override func onUpdate(view: UITableViewCell, context: ViewUpdateContext) {
        view.textLabel?.text = title
        view.accessoryType = .disclosureIndicator
    }

    override func calculateHeight(containerSize: CGSize) -> CGFloat {
        44
    }

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
        DemoEntry(title: "01  HelloDDComponent", vc: { HelloViewController() }),
        DemoEntry(title: "02  Service & DI", vc: { ServiceDIViewController() }),
        DemoEntry(title: "03  Notify", vc: { NotifyViewController() }),
        DemoEntry(title: "04  P-Tree", vc: { PTreeViewController() }),
        DemoEntry(title: "05  List & Diff", vc: { ListViewController() }),
        DemoEntry(title: "06  Header/Footer", vc: { HeaderFooterViewController() }),
        DemoEntry(title: "07  Animation & Context", vc: { AnimationViewController() }),
        DemoEntry(title: "08  IsolatedViewPresenter", vc: { IsolatedViewController() }),
        DemoEntry(title: "09  AutoBind & Shadow", vc: { AutoBindViewController() }),
        DemoEntry(title: "10  Feed Example", vc: { FeedViewController() }),
        DemoEntry(title: "CyclePageView", vc: { CyclePageViewController() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DDComponent Demo"

        let demos = self.demos
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
