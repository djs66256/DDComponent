import UIKit
import SnapKit
import Then

protocol LikeButtonViewable: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onTap: (() -> Void)? { get set }
}

final class LikeButtonView: UIView, LikeButtonViewable {
    var onTap: (() -> Void)?
    var isLiked: Bool = false {
        didSet { icon.text = isLiked ? "❤️" : "🤍"; animateHeart() }
    }
    var likeCount: Int = 0 { didSet { countLabel.text = "\(likeCount)" } }

    private let icon = UILabel().then { $0.font = .systemFont(ofSize: 18); $0.text = "🤍" }
    private let countLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .secondaryLabel; $0.text = "0" }

    override init(frame: CGRect) {
        super.init(frame: frame)
        [icon, countLabel].forEach(addSubview)
        icon.snp.makeConstraints { $0.left.centerY.equalToSuperview() }
        countLabel.snp.makeConstraints { $0.left.equalTo(icon.snp.right).offset(4); $0.centerY.equalToSuperview() }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func handleTap() { onTap?() }
    private func animateHeart() {
        UIView.animate(withDuration: 0.15, animations: { self.icon.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }) { _ in
            UIView.animate(withDuration: 0.15) { self.icon.transform = .identity }
        }
    }
}
