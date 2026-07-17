import UIKit
import SnapKit
import Then

protocol ServiceDIViewable: AnyObject {
    var dataLabel: UILabel { get }
    var counterLabel: UILabel { get }
    var loadButton: UIButton { get }
    var incrementButton: UIButton { get }
    var statusLabel: UILabel { get }
}

final class ServiceDIView: UIView, ServiceDIViewable {
    let dataLabel = UILabel().then {
        $0.text = "Tap Load Data"
        $0.font = .systemFont(ofSize: 17)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .label
    }

    let counterLabel = UILabel().then {
        $0.text = "Counter: 0"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .label
    }

    let loadButton = makeBtn(title: "Load Data (DataLoaderService)", color: .systemBlue)
    let incrementButton = makeBtn(title: "Increment (CounterService)", color: .systemGreen)

    let statusLabel = UILabel().then {
        $0.text = "Service status: idle"
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.textColor = .secondaryLabel
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        [dataLabel, counterLabel, loadButton, incrementButton, statusLabel].forEach(addSubview)

        dataLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        counterLabel.snp.makeConstraints { make in
            make.top.equalTo(dataLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
        }
        loadButton.snp.makeConstraints { make in
            make.top.equalTo(counterLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
        incrementButton.snp.makeConstraints { make in
            make.top.equalTo(loadButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(incrementButton.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private static func makeBtn(title: String, color: UIColor) -> UIButton {
        UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16)
            $0.backgroundColor = color
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 10
        }
    }
}
