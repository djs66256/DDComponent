import UIKit
import DDComponent

final class AutoBindViewController: PageViewController<AutoBindView, AutoBindRootPresenter, AutoBindRootViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "09  AutoBind & Shadow" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
    }
}
