import UIKit
import DDComponent

final class FeedViewController: UICollectionPageViewController<
    FeedRootPresenter, UICollectionView, UICollectionViewFlowLayout
> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "10  综合示例 — Feed"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "🆕", style: .plain, target: self, action: #selector(onNew)),
            UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(onRefresh)),
        ]
    }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, lazy: false) { MockLikeService() }
    }

    @objc private func onNew() { presenter.addPost() }
    @objc private func onRefresh() { presenter.refresh() }
}
