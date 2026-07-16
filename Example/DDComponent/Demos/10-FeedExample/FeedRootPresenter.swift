import UIKit
import DDComponent

/// Comprehensive demo: Service, Notify, Diff, Nested Presenters, Holder.
final class FeedRootPresenter: UICollectionViewRootPresenter<UICollectionView> {
    private var posts: [FeedPost] = [
        FeedPost(id: "1", name: "Alice", content: "DDComponent makes iOS architecture clean and testable!", isLiked: false, likeCount: 42),
        FeedPost(id: "2", name: "Bob", content: "P-Tree composition is the best pattern for complex pages.", isLiked: true, likeCount: 18),
        FeedPost(id: "3", name: "Carol", content: "The diff engine handles 1000+ items without breaking a sweat.", isLiked: false, likeCount: 56),
        FeedPost(id: "4", name: "Dave", content: "IsolatedViewPresenter lets you use Presenters anywhere — not just in PageViewController.", isLiked: true, likeCount: 7),
        FeedPost(id: "5", name: "Eve", content: "Service DI + Notify = clean cross-component communication.", isLiked: false, likeCount: 33),
    ]

    override func onAttach() {
        super.onAttach()
        buildSections()
    }

    func refresh() { posts.shuffle(); buildSections() }

    func addPost() {
        let new = FeedPost(id: String(UUID().uuidString.prefix(8)), name: "New User",
                           content: "Fresh post added with diff animation!", isLiked: false, likeCount: 0)
        posts.insert(new, at: 0); buildSections()
    }

    private func buildSections() {
        let holders: [FeedCardPresenterHolder] = posts.map { p in
            let h = FeedCardPresenterHolder(); h.post = p; return h
        }
        let section = UICollectionViewFlowSectionPresenter()
        section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        section.layoutInfo.lineSpacing = 12
        section.setItems(holders, animated: true)
        sections = [section]
    }
}
