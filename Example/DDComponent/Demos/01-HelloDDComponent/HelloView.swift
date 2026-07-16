import UIKit
import SnapKit
import Then

protocol HelloViewable: AnyObject {
    var countLabel: UILabel { get }
    var incrementButton: UIButton { get }
}

final class HelloView: UIView, HelloViewable {
    let countLabel = UILabel().then {
        $0.text = "0"
        $0.font = .systemFont(ofSize: 48, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .label
    }

    let incrementButton = UIButton(type: .system).then {
        $0.setTitle("+1", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        addSubview(countLabel)
        addSubview(incrementButton)

        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
        }

        incrementButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(countLabel.snp.bottom).offset(40)
            make.width.equalTo(120)
            make.height.equalTo(56)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
