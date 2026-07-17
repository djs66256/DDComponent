import UIKit
import DDComponent

final class AnimationViewController: PageViewController<AnimationView, AnimationRootPresenter> {
    override func viewDidLoad() { super.viewDidLoad(); title = "07  动画与 ViewUpdateContext" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
    }
}
