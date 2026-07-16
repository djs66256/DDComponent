import UIKit
import DDComponent

final class HeaderFooterViewController: UICollectionPageViewController<
    HeaderFooterRootPresenter, UICollectionView, UICollectionViewFlowLayout
> {
    override func viewDidLoad() { super.viewDidLoad(); title = "06  Header/Footer" }
}
