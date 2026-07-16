import UIKit
import SnapKit
import Then

protocol StarButtonViewable: AnyObject {
    var isStarred: Bool { get set }
    var onTap: (() -> Void)? { get set }
}

final class StarButton: UIButton, StarButtonViewable {
    var onTap: (() -> Void)?
    var isStarred: Bool = false {
        didSet {
            setTitle(isStarred ? "★" : "☆", for: .normal)
            tintColor = isStarred ? .systemYellow : .systemGray
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = .systemFont(ofSize: 40)
        setTitleColor(.systemYellow, for: .normal)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        isStarred = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func handleTap() { onTap?() }
}
