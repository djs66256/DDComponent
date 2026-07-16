import UIKit
import DDComponent

/// Uses UICollectionPageViewController with explicit generics to accept our custom presenter.
final class ListViewController: UICollectionPageViewController<
    ListRootPresenter, UICollectionView, UICollectionViewFlowLayout
> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "05  列表与部分更新"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "🔀", style: .plain, target: self, action: #selector(onShuffle)),
            UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(onAdd)),
            UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(onRemove)),
            UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(onReload)),
        ]
    }

    @objc private func onShuffle() { presenter.shuffle() }
    @objc private func onAdd() { presenter.addOne() }
    @objc private func onRemove() { presenter.removeOne() }
    @objc private func onReload() { presenter.reload() }
}
