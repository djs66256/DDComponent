import UIKit
import DDComponent

final class AnimationViewController: PageViewController<AnimationView, AnimationRootPresenter, AnimationViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "07  动画与 ViewUpdateContext" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { AnimationRootPresenter() }
    }
}
