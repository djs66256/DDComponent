import UIKit
import DDComponent

/// Minimal PageViewController subclass.
/// Generic params: FrameView, Presenter, View protocol.
/// @PageInstallerBuilder wires up the presenter.
final class HelloViewController: PageViewController<HelloView, HelloPresenter, HelloViewable> {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "01  HelloDDComponent"
    }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { HelloPresenter() }
    }
}
