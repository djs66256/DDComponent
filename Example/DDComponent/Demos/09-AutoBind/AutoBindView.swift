import UIKit
import SnapKit
import Then

protocol AutoBindRootViewable: AnyObject {
    var topSection: UIView { get }
    var middleSection: UIView { get }
    var bottomSection: UIView { get }
    var statusLabel: UILabel { get }
}

final class AutoBindView: UIView, AutoBindRootViewable {
    let topSection = UIView().then { $0.backgroundColor = .systemRed.withAlphaComponent(0.1); $0.layer.cornerRadius = 10 }
    let middleSection = UIView().then { $0.backgroundColor = .systemGreen.withAlphaComponent(0.1); $0.layer.cornerRadius = 10 }
    let bottomSection = UIView().then { $0.backgroundColor = .systemBlue.withAlphaComponent(0.1); $0.layer.cornerRadius = 10 }
    let statusLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textAlignment = .center; $0.textColor = .secondaryLabel; $0.numberOfLines = 0 }

    override init(frame: CGRect) {
        super.init(frame: frame); backgroundColor = .systemBackground
        [topSection, middleSection, bottomSection, statusLabel].forEach(addSubview)
        topSection.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20); make.left.right.equalToSuperview().inset(20); make.height.equalTo(80)
        }
        middleSection.snp.makeConstraints { make in
            make.top.equalTo(topSection.snp.bottom).offset(16); make.left.right.equalToSuperview().inset(20); make.height.equalTo(80)
        }
        bottomSection.snp.makeConstraints { make in
            make.top.equalTo(middleSection.snp.bottom).offset(16); make.left.right.equalToSuperview().inset(20); make.height.equalTo(80)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomSection.snp.bottom).offset(20); make.left.right.equalToSuperview().inset(20)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// View protocol for child presenters that auto-bind.
protocol AutoBindChildViewable: AnyObject {
    var sectionLabel: UILabel { get }
}

final class AutoBindChildView: UIView, AutoBindChildViewable {
    let sectionLabel = UILabel().then { $0.font = .systemFont(ofSize: 15, weight: .medium); $0.textAlignment = .center; $0.textColor = .label }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sectionLabel); sectionLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
