import UIKit
import SnapKit
import Then

protocol PresenterStateViewable: AnyObject {
    var countLabel: UILabel { get }
    var incrementButton: UIButton { get }
    var animatedButton: UIButton { get }
    var resetButton: UIButton { get }
}

final class PresenterStateView: UIView, PresenterStateViewable {
    let countLabel = UILabel().then {
        $0.text = "0"
        $0.font = .systemFont(ofSize: 48, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .label
    }

    let incrementButton = UIButton(type: .system).then {
        $0.setTitle("+1 (Default)", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
    }

    let animatedButton = UIButton(type: .system).then {
        $0.setTitle("+5 (Animated)", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.backgroundColor = .systemOrange
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
    }

    let resetButton = UIButton(type: .system).then {
        $0.setTitle("Reset", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.backgroundColor = .systemRed
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        addSubview(countLabel)
        addSubview(incrementButton)
        addSubview(animatedButton)
        addSubview(resetButton)

        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }

        incrementButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(countLabel.snp.bottom).offset(30)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }

        animatedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(incrementButton.snp.bottom).offset(16)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }

        resetButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(animatedButton.snp.bottom).offset(16)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}