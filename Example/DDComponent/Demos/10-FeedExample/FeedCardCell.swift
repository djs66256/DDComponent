import UIKit
import SnapKit
import Then

final class FeedCardCell: UICollectionViewCell {
    let avatarView = UIView().then { $0.backgroundColor = .systemGray4; $0.layer.cornerRadius = 20 }
    let nameLabel = UILabel().then { $0.font = .systemFont(ofSize: 15, weight: .semibold); $0.textColor = .label }
    let contentLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .label; $0.numberOfLines = 3 }
    let imagePlaceholder = UIView().then { $0.backgroundColor = .systemGray5; $0.layer.cornerRadius = 6 }
    let likeContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12; contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor

        [avatarView, nameLabel, contentLabel, imagePlaceholder, likeContainer].forEach { contentView.addSubview($0) }

        avatarView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12); make.width.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(8); make.centerY.equalTo(avatarView)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(12)
        }
        imagePlaceholder.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(12); make.height.equalTo(60)
        }
        likeContainer.snp.makeConstraints { make in
            make.top.equalTo(imagePlaceholder.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(12); make.height.equalTo(30); make.bottom.equalToSuperview().offset(-12)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

struct FeedPost {
    let id: String; let name: String; let content: String; var isLiked: Bool; var likeCount: Int
}
