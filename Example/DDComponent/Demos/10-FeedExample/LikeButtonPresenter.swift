import UIKit
import DDComponent

/// Listener: notified when like state changes.
protocol LikeChangeListener: AnyObject {
    func onLikeChanged(postId: String, isLiked: Bool, likeCount: Int)
}

final class LikeButtonPresenter: ViewPresenter<LikeButtonViewable> {
    var postId: String = ""
    private var isLiked: Bool = false { didSet { setState {} } }
    private var likeCount: Int = 0 { didSet { setState {} } }

    func configure(postId: String, isLiked: Bool, likeCount: Int) {
        self.postId = postId; self.isLiked = isLiked; self.likeCount = likeCount
    }

    override func onBindView(_ view: LikeButtonViewable) {
        super.onBindView(view)
        view.onTap = { [weak self] in self?.handleTap() }
    }

    override func onUpdate(view: LikeButtonViewable, context: ViewUpdateContext) {
        view.isLiked = isLiked; view.likeCount = likeCount
    }

    private func handleTap() {
        guard let service = getService(LikeService.self) else { return }
        service.toggleLike(postId: postId, isLiked: isLiked) { [weak self] newLiked, newCount, _ in
            self?.setState { self?.isLiked = newLiked; self?.likeCount = newCount }
            // notifyReusable: notify nearest reusable parent (the card presenter)
            self?.notify(listener: LikeChangeListener.self, scope: .reusable) {
                $0.onLikeChanged(postId: self?.postId ?? "", isLiked: newLiked, likeCount: newCount)
            }
        }
    }
}
