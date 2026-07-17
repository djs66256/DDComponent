import UIKit
import DDComponent

/// Demonstrates the `use*` methods API — React Hooks-like pattern for DDComponent.
///
/// See `UseMethodsRootPresenter` for the full set of `use*` method usage.
final class UseMethodsViewController: PageViewController<UseMethodsView, UseMethodsRootPresenter> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "11  Use Methods"
    }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
    }
}