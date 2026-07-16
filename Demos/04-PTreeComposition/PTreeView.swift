import UIKit
import SnapKit
import Then

struct Theme {
    let name: String; let bgColor: UIColor; let textColor: UIColor
    static let light = Theme(name: "Light", bgColor: .systemGray6, textColor: .label)
    static let dark = Theme(name: "Dark", bgColor: .darkGray, textColor: .white)
}

protocol PTreeViewable: AnyObject {
    var headerContainer: UIView { get }
    var bodyContainer: UIView { get }
    var footerContainer: UIView { get }
    var themeToggle: UIButton { get }
}

final class PTreeView: UIView, PTreeViewable {
    let headerContainer = UIView()
    let bodyContainer = UIView()
    let footerContainer = UIView()

    let themeToggle = UIButton(type: .system).then {
        $0.setTitle("Toggle Theme", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = .systemIndigo; $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame); backgroundColor = .systemBackground
        [themeToggle, headerContainer, bodyContainer, footerContainer].forEach(addSubview)
        themeToggle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16); make.centerX.equalToSuperview()
            make.width.equalTo(180); make.height.equalTo(44)
        }
        headerContainer.snp.makeConstraints { make in
            make.top.equalTo(themeToggle.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20); make.height.equalTo(80)
        }
        bodyContainer.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20); make.height.greaterThanOrEqualTo(120)
        }
        footerContainer.snp.makeConstraints { make in
            make.top.equalTo(bodyContainer.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20); make.height.equalTo(60)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

protocol ThemeableViewable: AnyObject {
    func applyTheme(_ theme: Theme)
}

final class ThemeableContainerView: UIView, ThemeableViewable {
    let titleLabel = UILabel().then { $0.font = .systemFont(ofSize: 16); $0.numberOfLines = 0; $0.textAlignment = .center }
    override init(frame: CGRect) {
        super.init(frame: frame); layer.cornerRadius = 10
        addSubview(titleLabel); titleLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func applyTheme(_ theme: Theme) { backgroundColor = theme.bgColor; titleLabel.textColor = theme.textColor }
}
