import UIKit
import SnapKit
import Then

final class CardCell: UICollectionViewCell {
    let colorBar = UIView().then { $0.layer.cornerRadius = 3 }
    let titleLabel = UILabel().then { $0.font = .systemFont(ofSize: 17, weight: .semibold); $0.textColor = .label }
    let detailLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .secondaryLabel; $0.numberOfLines = 2 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10; contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
        [colorBar, titleLabel, detailLabel].forEach { contentView.addSubview($0) }
        colorBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12); make.height.equalTo(4)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(colorBar.snp.bottom).offset(8); make.left.right.equalToSuperview().inset(12)
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4); make.left.right.bottom.equalToSuperview().inset(12)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ data: CardData) {
        titleLabel.text = data.title; detailLabel.text = data.detail; colorBar.backgroundColor = data.color
    }
}
