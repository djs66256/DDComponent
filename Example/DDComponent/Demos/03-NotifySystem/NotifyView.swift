import UIKit
import SnapKit
import Then

protocol NotifyZoneViewable: AnyObject {
    var zoneTitle: String? { get set }
    var zoneColor: UIColor { get set }
    var onTap: (() -> Void)? { get set }
}

final class NotifyZoneView: UIView, NotifyZoneViewable {
    var onTap: (() -> Void)?
    var zoneTitle: String? { didSet { titleLabel.text = zoneTitle } }
    var zoneColor: UIColor = .systemGray6 { didSet { backgroundColor = zoneColor } }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .center; $0.textColor = .label; $0.numberOfLines = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10; layer.borderWidth = 1; layer.borderColor = UIColor.separator.cgColor
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func handleTap() { onTap?() }
}

final class NotifyLoggerZoneView: UIView, NotifyLoggerViewable {
    var highlightColor: UIColor = .clear { didSet { backgroundColor = highlightColor } }
    var logText: String = "" { didSet { textView.text = logText } }

    private let textView = UITextView().then {
        $0.isEditable = false; $0.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        $0.backgroundColor = .clear
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10; layer.borderWidth = 1; layer.borderColor = UIColor.separator.cgColor
        addSubview(textView)
        textView.snp.makeConstraints { $0.edges.equalToSuperview().inset(8) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

protocol NotifyDemoViewable: AnyObject {
    var globalZone: NotifyZoneView { get }
    var parentZone: NotifyZoneView { get }
    var childZone: NotifyZoneView { get }
    var reusableZone: NotifyZoneView { get }
    var loggerZone: NotifyLoggerZoneView { get }
}

final class NotifyDemoView: UIView, NotifyDemoViewable {
    let globalZone = NotifyZoneView().then { $0.zoneTitle = "🌐 Global — Tap to broadcast" }
    let parentZone = NotifyZoneView().then { $0.zoneTitle = "⬇️ Parent — Tap to notifyChildren" }
    let childZone = NotifyZoneView().then { $0.zoneTitle = "⬆️ Child — Tap to notifyParents" }
    let reusableZone = NotifyZoneView().then { $0.zoneTitle = "♻️ Reusable — Tap to notifyReusable" }
    let loggerZone = NotifyLoggerZoneView().then { $0.logText = "Tap zones to fire notifications..." }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        let stack = UIStackView(arrangedSubviews: [globalZone, parentZone, childZone, reusableZone, loggerZone]).then {
            $0.axis = .vertical; $0.spacing = 10; $0.distribution = .fillEqually
        }
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-10)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
