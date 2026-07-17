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

        /// autoBind: each child presenter has a distinct View TYPE.
        /// BFS walks subviews and binds `view as? T` — first match wins.
        /// So each section gets a child that conforms to ONLY its protocol.
        let topChild = TopSectionChildView()
        let middleChild = MiddleSectionChildView()
        let bottomChild = BottomSectionChildView()
        topSection.addSubview(topChild)
        middleSection.addSubview(middleChild)
        bottomSection.addSubview(bottomChild)
        [topChild, middleChild, bottomChild].forEach {
            $0.snp.makeConstraints { $0.edges.equalToSuperview() }
        }

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

// MARK: - Distinct View protocols for autoBind type matching

/// autoBind matches by Swift type via BFS (`view as? T`).
/// Each presenter must use a **unique** View protocol so BFS can distinguish them.
protocol TopSectionViewable: AnyObject {
    var sectionLabel: UILabel { get }
}
protocol MiddleSectionViewable: AnyObject {
    var sectionLabel: UILabel { get }
}
protocol BottomSectionViewable: AnyObject {
    var sectionLabel: UILabel { get }
}

/// Each child view conforms to only ONE protocol.
/// This is essential: if a view conformed to all three, BFS would
/// match the first one for every presenter.

final class TopSectionChildView: UIView, TopSectionViewable {
    let sectionLabel = UILabel().then { $0.font = .systemFont(ofSize: 15, weight: .medium); $0.textAlignment = .center; $0.textColor = .label }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sectionLabel); sectionLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class MiddleSectionChildView: UIView, MiddleSectionViewable {
    let sectionLabel = UILabel().then { $0.font = .systemFont(ofSize: 15, weight: .medium); $0.textAlignment = .center; $0.textColor = .label }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sectionLabel); sectionLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class BottomSectionChildView: UIView, BottomSectionViewable {
    let sectionLabel = UILabel().then { $0.font = .systemFont(ofSize: 15, weight: .medium); $0.textAlignment = .center; $0.textColor = .label }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sectionLabel); sectionLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
