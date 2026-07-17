import UIKit
import SnapKit
import Then

protocol AnimationViewable: AnyObject {
    var square: UIView { get }
    var moveBtn: UIButton { get }
    var resizeBtn: UIButton { get }
    var colorBtn: UIButton { get }
    var layoutBtn: UIButton { get }
    var infoLabel: UILabel { get }
}

final class AnimationView: UIView, AnimationViewable {
    let square = UIView().then { $0.backgroundColor = .systemBlue; $0.layer.cornerRadius = 8 }
    let infoLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textAlignment = .center; $0.textColor = .secondaryLabel; $0.numberOfLines = 0 }
    let moveBtn = makeBtn("Move + Rotate (default animate)", .systemBlue)
    let resizeBtn = makeBtn("Resize (spring bounce)", .systemPurple)
    let colorBtn = makeBtn("Rotate + Color (slow 1.2s)", .systemGray)
    let layoutBtn = makeBtn("Expand All (default animate)", .systemOrange)

    private var squareTopConstraint: Constraint?
    private var squareSizeConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame); backgroundColor = .systemBackground
        [square, infoLabel, moveBtn, resizeBtn, colorBtn, layoutBtn].forEach(addSubview)

        square.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            squareTopConstraint = make.top.equalTo(safeAreaLayoutGuide).offset(120).constraint
            squareSizeConstraint = make.width.height.equalTo(80).constraint
        }
        moveBtn.snp.makeConstraints { make in
            make.top.equalTo(square.snp.bottom).offset(50); make.left.right.equalToSuperview().inset(40); make.height.equalTo(44)
        }
        resizeBtn.snp.makeConstraints { make in
            make.top.equalTo(moveBtn.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(40); make.height.equalTo(44)
        }
        colorBtn.snp.makeConstraints { make in
            make.top.equalTo(resizeBtn.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(40); make.height.equalTo(44)
        }
        layoutBtn.snp.makeConstraints { make in
            make.top.equalTo(colorBtn.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(40); make.height.equalTo(44)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(layoutBtn.snp.bottom).offset(16); make.left.right.equalToSuperview().inset(20)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private static func makeBtn(_ title: String, _ color: UIColor) -> UIButton {
        UIButton(type: .system).then {
            $0.setTitle(title, for: .normal); $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            $0.backgroundColor = color; $0.setTitleColor(.white, for: .normal); $0.layer.cornerRadius = 10
        }
    }
}
