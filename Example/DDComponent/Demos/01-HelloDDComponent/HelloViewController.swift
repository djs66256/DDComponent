import UIKit
import DDComponent

/// Root presenter wraps HelloPresenter as a child via typeBox.
/// PageViewController requires Presenter to be a RootViewPresenter subclass.
final class HelloRootPresenter: RootViewPresenter<HelloViewable> {

    required init() {
        super.init()
        autoBindView = true
        typeBox(HelloPresenter())
    }
}

/// Minimal PageViewController subclass.
/// Generic params: FrameView (UIView), Presenter (RootViewPresenterProtocol).
final class HelloViewController: PageViewController<HelloView, HelloRootPresenter> {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "01  HelloDDComponent"
    }
}
