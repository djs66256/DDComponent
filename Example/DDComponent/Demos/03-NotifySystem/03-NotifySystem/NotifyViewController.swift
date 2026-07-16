import UIKit
import DDComponent

final class NotifyViewController: PageViewController<NotifyDemoView, NotifyRootPresenter, NotifyDemoViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "03  Notify 事件系统" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { NotifyRootPresenter() }
    }
}
