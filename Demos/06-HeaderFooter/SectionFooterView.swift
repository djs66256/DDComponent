import UIKit
import SnapKit
import Then

protocol SectionFooterViewable: AnyObject { var text: String? { get set } }

final class SectionFooterView: UICollectionReusableView, SectionFooterViewable {
    var text: String? { didSet { label.text = text } }
    private let label = UILabel().then { $0.font = .systemFont(ofSize: 12); $0.textColor = .tertiaryLabel; $0.textAlignment = .right }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label); label.snp.makeConstraints { $0.right.equalToSuperview().offset(-16); $0.centerY.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
