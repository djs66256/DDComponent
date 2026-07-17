import UIKit
import SnapKit
import Then

// MARK: - View Protocol

protocol UseMethodsViewable: AnyObject {
    // updateTo keyPath targets
    var counterDisplay: Int { get set }
    var nicknameDisplay: String? { get set }
    var publisherDisplay: String { get set }
    var sequenceDisplay: Int { get set }
    var viewModelDisplay: CounterViewModel? { get set }
    var optionalViewModelDisplay: CounterViewModel? { get set }
    var servicePublisherDisplay: String { get set }
    var serviceSequenceDisplay: Int { get set }

    // updater target labels
    var counterWithUpdaterLabel: UILabel { get }
    var optionalWithUpdaterLabel: UILabel { get }
    var publisherWithUpdaterLabel: UILabel { get }
    var sequenceWithUpdaterLabel: UILabel { get }
    var viewModelWithUpdaterLabel: UILabel { get }
    var optionalViewModelWithUpdaterLabel: UILabel { get }
    var servicePublisherWithUpdaterLabel: UILabel { get }
    var serviceSequenceWithUpdaterLabel: UILabel { get }

    // Buttons
    var incButton: UIButton { get }
    var decButton: UIButton { get }
    var setOptButton: UIButton { get }
    var clearOptButton: UIButton { get }
    var newObjButton: UIButton { get }
    var clearObjButton: UIButton { get }
    var vmIncButton: UIButton { get }
    var vmDecButton: UIButton { get }
    var replaceVMButton: UIButton { get }
    var clearVMButton: UIButton { get }

    // Status
    var statusLabel: UILabel { get }
}

// MARK: - View

final class UseMethodsView: UIScrollView, UseMethodsViewable {

    // updateTo keyPath targets
    var counterDisplay: Int = 0 {
        didSet { counterDisplayLabel.text = "counterDisplay = \(counterDisplay)" }
    }
    var nicknameDisplay: String? = nil {
        didSet { nicknameDisplayLabel.text = "nicknameDisplay = \(nicknameDisplay ?? "nil")" }
    }
    var publisherDisplay: String = "" {
        didSet { publisherDisplayLabel.text = "pubDisplay = \(publisherDisplay)" }
    }
    var sequenceDisplay: Int = 0 {
        didSet { sequenceDisplayLabel.text = "seqDisplay = \(sequenceDisplay)" }
    }
    var viewModelDisplay: CounterViewModel? = nil {
        didSet { viewModelDisplayLabel.text = "vmDisplay.label = \(viewModelDisplay?.label ?? "nil")" }
    }
    var optionalViewModelDisplay: CounterViewModel? = nil {
        didSet { optVMDisplayLabel.text = "optVMDisplay.label = \(optionalViewModelDisplay?.label ?? "nil")" }
    }
    var servicePublisherDisplay: String = "" {
        didSet { svcPubDisplayLabel.text = "svcPubDisplay = \(servicePublisherDisplay)" }
    }
    var serviceSequenceDisplay: Int = 0 {
        didSet { svcSeqDisplayLabel.text = "svcSeqDisplay = \(serviceSequenceDisplay)" }
    }

    // updater target labels
    let counterWithUpdaterLabel = makeInfoLabel()
    let optionalWithUpdaterLabel = makeInfoLabel()
    let publisherWithUpdaterLabel = makeInfoLabel()
    let sequenceWithUpdaterLabel = makeInfoLabel()
    let viewModelWithUpdaterLabel = makeInfoLabel()
    let optionalViewModelWithUpdaterLabel = makeInfoLabel()
    let servicePublisherWithUpdaterLabel = makeInfoLabel()
    let serviceSequenceWithUpdaterLabel = makeInfoLabel()

    // updateTo display labels
    let counterDisplayLabel = makeInfoLabel()
    let nicknameDisplayLabel = makeInfoLabel()
    let publisherDisplayLabel = makeInfoLabel()
    let sequenceDisplayLabel = makeInfoLabel()
    let viewModelDisplayLabel = makeInfoLabel()
    let optVMDisplayLabel = makeInfoLabel()
    let svcPubDisplayLabel = makeInfoLabel()
    let svcSeqDisplayLabel = makeInfoLabel()

    // Buttons
    let incButton = makeButton("+ Increment")
    let decButton = makeButton("− Decrement")
    let setOptButton = makeButton("Set Optional")
    let clearOptButton = makeButton("Clear Optional")
    let newObjButton = makeButton("New Object")
    let clearObjButton = makeButton("Clear Object")
    let vmIncButton = makeButton("VM +")
    let vmDecButton = makeButton("VM −")
    let replaceVMButton = makeButton("Replace VM")
    let clearVMButton = makeButton("Clear Optional VM")

    // Status
    let statusLabel = UILabel().then {
        $0.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        alwaysBounceVertical = true
        backgroundColor = .systemBackground

        let stack = UIStackView(arrangedSubviews: [
            section("1. useState<T: Equatable>",
                    "counter = useState(0)\noptionalCounter = useState<Int?>(nil)",
                    incButton, decButton, setOptButton, clearOptButton),
            divider(),
            section("2. useState<T: AnyObject>",
                    "selectedObject = useState(NSObject())\noptionalObject = useState<NSObject?>(nil)",
                    newObjButton, clearObjButton),
            divider(),
            section("3. useState<T> (unconstrained)",
                    "timestamp = useState(Date())\noptionalTimestamp = useState<Date?>(nil)\n(updated by useEffect timer every 1s)",
                    UIView()),
            divider(),
            section("4. useState + updater:",
                    "counterWithUpdater = useState(0, updater: { value, view, _ in ... })",
                    counterWithUpdaterLabel, optionalWithUpdaterLabel),
            divider(),
            section("5. useState + updateTo:",
                    "counterWithKeyPath = useState(0, updateTo: \\.counterDisplay)",
                    counterDisplayLabel, nicknameDisplayLabel),
            divider(),
            section("6. useState + Publisher",
                    "publisherValue = useState(\"\", publisher: timerPub)",
                    publisherWithUpdaterLabel, publisherDisplayLabel),
            divider(),
            section("7. useState + AsyncSequence",
                    "sequenceValue = useState(0, sequence: asyncSeq)",
                    sequenceWithUpdaterLabel, sequenceDisplayLabel),
            divider(),
            section("8. useState + ObservableObject",
                    "viewModel = useState(CounterViewModel())\noptionalViewModel = useState<CounterViewModel?>(vm)",
                    vmIncButton, vmDecButton, replaceVMButton, clearVMButton,
                    viewModelWithUpdaterLabel, optionalViewModelWithUpdaterLabel,
                    viewModelDisplayLabel, optVMDisplayLabel),
            divider(),
            section("9. useService + useState(publisher:)",
                    "servicePublisherValue = useState(service: ..., publisher: ...)",
                    servicePublisherWithUpdaterLabel, svcPubDisplayLabel),
            divider(),
            section("10. useService + useState(sequence:)",
                    "serviceSequenceValue = useState(service: ..., sequence: ...)",
                    serviceSequenceWithUpdaterLabel, svcSeqDisplayLabel),
            divider(),
            section("11. useEffect",
                    "timerEffect = useEffect { start timer; return { invalidate } }\nlogEffect = useEffect { print(...) }",
                    UIView()),
            divider(),
            section("12. useService",
                    "serviceEffect = useService(MyService.self) { svc in ... }",
                    UIView()),
            divider(),
            section("Status", "", statusLabel),
        ]).then {
            $0.axis = .vertical
            $0.spacing = 12
            $0.alignment = .fill
        }

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalToSuperview().offset(-32)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers

private func section(_ title: String,
                     _ subtitle: String,
                     _ views: UIView...) -> UIView {
    let header = UILabel().then {
        $0.text = title
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .systemBlue
    }
    let sub = UILabel().then {
        $0.text = subtitle
        $0.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }
    let container = UIStackView(arrangedSubviews: [header, sub] + views).then {
        $0.axis = .vertical
        $0.spacing = 6
    }
    return container
}

private func divider() -> UIView {
    UIView().then {
        $0.backgroundColor = .separator
        $0.snp.makeConstraints { $0.height.equalTo(1) }
    }
}

private func makeInfoLabel() -> UILabel {
    UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }
}

private func makeButton(_ title: String) -> UIButton {
    UIButton(type: .system).then {
        $0.setTitle(title, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        $0.contentHorizontalAlignment = .leading
    }
}