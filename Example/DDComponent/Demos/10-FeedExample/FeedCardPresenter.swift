import UIKit
import SnapKit
import DDComponent

/// Reusable presenter for a feed card. Uses nested child presenters.
final class FeedCardPresenter: ReusableViewPresenter<FeedCardCell> {
    let likePresenter = LikeButtonPresenter()

    required init() {
        super.init()
        add(child: likePresenter)
    }

    var post: FeedPost? {
        didSet {
            guard let p = post else { return }
            likePresenter.configure(postId: p.id, isLiked: p.isLiked, likeCount: p.likeCount)
            setState {}
        }
    }

    override func onBindView(_ view: FeedCardCell) {
        super.onBindView(view)
        // Bind child like presenter to the like container in the cell
        let likeView = LikeButtonView()
        view.likeContainer.addSubview(likeView)
        likeView.snp.makeConstraints { $0.left.centerY.equalToSuperview() }
        likePresenter.bindView(likeView)
    }

    override func onUpdate(view: FeedCardCell, context: ViewUpdateContext) {
        guard let p = post else { return }
        view.nameLabel.text = p.name
        view.contentLabel.text = p.content
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        post = nil
    }
}

// MARK: - LikeChangeListener (receives notifyReusable from child like presenter)

extension FeedCardPresenter: LikeChangeListener {
    func onLikeChanged(postId: String, isLiked: Bool, likeCount: Int) {
        post?.isLiked = isLiked
        post?.likeCount = likeCount
        print("[Feed] Like changed: post=\(postId) liked=\(isLiked) count=\(likeCount)")
    }
}

/// Holder + flow layout info for the feed card in a CollectionView section.
final class FeedCardPresenterHolder: UICollectionViewFlowItemPresenterHolder<FeedCardPresenter, FeedCardCell> {
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }

    var post: FeedPost? { didSet { setState {} } }

    override func onUpdate(presenter: FeedCardPresenter, context: ViewUpdateContext) {
        presenter.post = post
    }
}
