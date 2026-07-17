import UIKit
import DDComponent

/// Minimal PageViewController subclass.
final class PresenterStateViewController: PageViewController<PresenterStateView, PresenterStateRootPresenter> {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "12  @PresenterState"
    }
}