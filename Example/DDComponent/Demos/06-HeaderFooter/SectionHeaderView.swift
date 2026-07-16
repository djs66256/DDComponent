import UIKit
import SnapKit
import Then

protocol SectionHeaderViewable: AnyObject {
    var title: String? { get set }
    var isCollapsed: Bool { get set }
    var onTap: (() -> Void)? { get set }
}

final class SectionHeaderView: UICollectionReusableView, SectionHeaderViewable {
    var onTap: (() -> Void)?
    var title: String? { didSet { label.text = title } }
    var isCollapsed: Bool = false { didSet { indicator.text = isCollapsed ? "▶" : "▼" } }

    private let label = UILabel().then { $0.font = .systemFont(ofSize: 16, weight: .bold); $0.textColor = .label }
    private let indicator = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .secondaryLabel }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray5; layer.cornerRadius = 8
        [label, indicator].forEach(addSubview)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16); make.centerY.equalToSuperview()
        }
        indicator.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16); make.centerY.equalToSuperview()
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func handleTap() { onTap?() }
}
