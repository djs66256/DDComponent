import Foundation

protocol LikeService: AnyObject {
    func toggleLike(postId: String, isLiked: Bool, completion: @escaping (Bool, Int, Error?) -> Void)
}

final class MockLikeService: LikeService {
    func toggleLike(postId: String, isLiked: Bool, completion: @escaping (Bool, Int, Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(!isLiked, isLiked ? 41 : 42, nil)
        }
    }
}
