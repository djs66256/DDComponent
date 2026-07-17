import UIKit
import DDComponent

final class PTreeViewController: PageViewController<PTreeView, PTreeRootPresenter> {
    override func viewDidLoad() { super.viewDidLoad(); title = "04  P-Tree 组合" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        
    }
}
