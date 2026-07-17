import UIKit
import DDComponent

final class CyclePageViewController: PageViewController<CyclePageDemoView, CyclePageRootPresenter> {
    override func viewDidLoad() { super.viewDidLoad(); title = "CyclePageView 集成" }
}
