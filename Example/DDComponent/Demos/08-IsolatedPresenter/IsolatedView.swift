import UIKit
import SnapKit

protocol IsolatedDemoViewable: AnyObject {
    var stackView: UIStackView { get }
}

final class IsolatedDemoView: UIView, IsolatedDemoViewable {
    let stackView = UIStackView().then { $0.axis = .vertical; $0.spacing = 20; $0.alignment = .center }
    override init(frame: CGRect) {
        super.init(frame: frame); backgroundColor = .systemBackground
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
