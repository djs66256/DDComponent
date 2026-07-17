import UIKit
import DDComponent

final class IsolatedViewController: PageViewController<IsolatedDemoView, IsolatedRootPresenter> {
    override func viewDidLoad() { super.viewDidLoad(); title = "08  IsolatedViewPresenter" }
}
