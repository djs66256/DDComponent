import UIKit
import DDComponent
import Combine

// MARK: - ObservableObject ViewModel

final class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var label: String = "zero"

    func increment() {
        count += 1
        label = count == 0 ? "zero" : "\(count)"
    }

    func decrement() {
        count -= 1
        label = count == 0 ? "zero" : "\(count)"
    }
}

// MARK: - Service

final class UseMethodsService: Service {
    func tickPublisher() -> AnyPublisher<String, Never> {
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .map { "svc-pub: \(Int($0.timeIntervalSince1970))" }
            .eraseToAnyPublisher()
    }

    func tickSequence() -> AsyncStream<Int> {
        AsyncStream { continuation in
            Task {
                for i in 0... {
                    continuation.yield(i)
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                }
            }
        }
    }
}

// MARK: - Root Presenter

final class UseMethodsRootPresenter: RootViewPresenter<UseMethodsViewable> {

    // All `lazy var` — deferred init avoids Swift 6 `self` before `super.init()` issue.
    // Each property is initialized on first access, after the presenter is fully initialized.

    // 1. Equatable
    lazy var counter = useState(0)
    lazy var optionalCounter: State<Int?> = useState(nil)

    // 2. AnyObject
    lazy var selectedObject: State<NSObject> = useState(NSObject())
    lazy var optionalObject: State<NSObject?> = useState(nil)

    // 3. Unconstrained
    lazy var timestamp: State<Date> = useState(Date())
    lazy var optionalTimestamp: State<Date?> = useState(nil)

    // 4. With updater
    lazy var counterWithUpdater: State<Int> = useState(0, updater: { [weak self] value, view, _ in
        view.counterWithUpdaterLabel.text = "counterWithUpdater: \(value)"
    })
    lazy var optionalWithUpdater = useState(nil, updater: { value, view, _ in
        view.optionalWithUpdaterLabel.text = "optionalWithUpdater: \(value ?? "nil")"
    })

    // 5. With updateTo (using updater — updateTo keyPath requires View: AnyObject)
    lazy var counterWithKeyPath = useState(0, updater: { value, view, _ in
        view.counterDisplay = value
    })
    lazy var optionalWithKeyPath = useState(nil, updater: { value, view, _ in
        view.nicknameDisplay = value
    })

    // 6. Publisher
    lazy var publisherValue: State<String> = {
        let pub = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
            .map { "pub: \(Int($0.timeIntervalSince1970))" }.eraseToAnyPublisher()
        return useState("(waiting)", publisher: pub)
    }()
    lazy var publisherOptional = useState(nil, publisher: Just("opt-pub").eraseToAnyPublisher())
    lazy var publisherWithUpdater: State<String> = {
        let pub = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
            .map { "pub: \(Int($0.timeIntervalSince1970))" }.eraseToAnyPublisher()
        return useState("(waiting)", updater: { value, view, _ in
            view.publisherWithUpdaterLabel.text = "pub+updater: \(value)"
        }, publisher: pub)
    }()
    lazy var publisherWithKeyPath: State<String> = {
        let pub = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
            .map { "pub: \(Int($0.timeIntervalSince1970))" }.eraseToAnyPublisher()
        return useState("(waiting)", updater: { value, view, _ in
            view.publisherDisplay = value
        }, publisher: pub)
    }()

    // 7. AsyncSequence
    private let tickSeq = AsyncStream<Int> { continuation in
        Task {
            for i in 0... { continuation.yield(i); try? await Task.sleep(nanoseconds: 2_000_000_000) }
        }
    }
    lazy var sequenceValue = useState(0, sequence: tickSeq)
    lazy var sequenceOptional = useState(nil, sequence: tickSeq.map { $0 as Int? })
    lazy var sequenceWithUpdater = useState(0, updater: { value, view, _ in
        view.sequenceWithUpdaterLabel.text = "seq+updater: \(value)"
    }, sequence: tickSeq)
    lazy var sequenceWithKeyPath = useState(0, updater: { value, view, _ in
        view.sequenceDisplay = value
    }, sequence: tickSeq)

    // 8. ObservableObject
    lazy var viewModel = useState(CounterViewModel())
    lazy var optionalViewModel: State<CounterViewModel?> = useState(nil)
    lazy var viewModelWithUpdater = useState(CounterViewModel(), updater: { value, view, _ in
        view.viewModelWithUpdaterLabel.text = "vm+updater: \(value.label)"
    })
    lazy var optionalViewModelWithUpdater: State<CounterViewModel?> = useState(nil, updater: { value, view, _ in
        view.optionalViewModelWithUpdaterLabel.text = "optVM+updater: \(value?.label ?? "nil")"
    })
    lazy var viewModelWithKeyPath: State<CounterViewModel> = useState(CounterViewModel(), updater: { value, view, _ in
        view.viewModelDisplay = value
    })
    lazy var optionalViewModelWithKeyPath: State<CounterViewModel?> = useState(nil, updater: { value, view, _ in
        view.optionalViewModelDisplay = value
    })

    // 9. Service + Publisher
    lazy var servicePublisherValue = useState("(waiting)", service: UseMethodsService.self, publisher: { $0.tickPublisher() })
    lazy var servicePublisherWithUpdater = useState("(waiting)", updater: { value, view, _ in
        view.servicePublisherWithUpdaterLabel.text = "svcPub+updater: \(value)"
    }, service: UseMethodsService.self, publisher: { $0.tickPublisher() })
    lazy var servicePublisherWithKeyPath = useState("(waiting)", updater: { value, view, _ in
        view.servicePublisherDisplay = value
    }, service: UseMethodsService.self, publisher: { $0.tickPublisher() })

    // 10. Service + Sequence
    lazy var serviceSequenceValue = useState(0, service: UseMethodsService.self, sequence: { $0.tickSequence() })
    lazy var serviceSequenceWithUpdater = useState(0, updater: { value, view, _ in
        view.serviceSequenceWithUpdaterLabel.text = "svcSeq+updater: \(value)"
    }, service: UseMethodsService.self, sequence: { $0.tickSequence() })
    lazy var serviceSequenceWithKeyPath = useState(0, updater: { value, view, _ in
        view.serviceSequenceDisplay = value
    }, service: UseMethodsService.self, sequence: { $0.tickSequence() })

    // 11. useEffect
    lazy var timerEffect = useEffect { [weak self] in
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.timestamp.value = Date() }
        }
        return { timer.invalidate() }
    }
    lazy var logEffect = useEffect { print("[UseMethods] attached to root") }

    // 12. useService
    lazy var serviceEffect = useService(UseMethodsService.self) { _ in
        print("[UseMethods] service resolved")
        return { print("[UseMethods] service cleanup") }
    }

    // MARK: Lifecycle

    required init() {
        super.init()
        // Trigger lazy init by accessing each property once
        _ = counter; _ = optionalCounter; _ = selectedObject; _ = optionalObject
        _ = timestamp; _ = optionalTimestamp
        _ = counterWithUpdater; _ = optionalWithUpdater; _ = counterWithKeyPath; _ = optionalWithKeyPath
        _ = publisherValue; _ = publisherOptional; _ = publisherWithUpdater; _ = publisherWithKeyPath
        _ = sequenceValue; _ = sequenceOptional; _ = sequenceWithUpdater; _ = sequenceWithKeyPath
        _ = viewModel; _ = optionalViewModel; _ = viewModelWithUpdater; _ = optionalViewModelWithUpdater
        _ = viewModelWithKeyPath; _ = optionalViewModelWithKeyPath
        _ = servicePublisherValue; _ = servicePublisherWithUpdater; _ = servicePublisherWithKeyPath
        _ = serviceSequenceValue; _ = serviceSequenceWithUpdater; _ = serviceSequenceWithKeyPath
        _ = timerEffect; _ = logEffect; _ = serviceEffect
    }

    // MARK: Lifecycle

    override func onBindView(_ view: UseMethodsViewable) {
        super.onBindView(view)
        view.incButton.addTarget(self, action: #selector(onInc), for: .touchUpInside)
        view.decButton.addTarget(self, action: #selector(onDec), for: .touchUpInside)
        view.setOptButton.addTarget(self, action: #selector(onSetOpt), for: .touchUpInside)
        view.clearOptButton.addTarget(self, action: #selector(onClearOpt), for: .touchUpInside)
        view.newObjButton.addTarget(self, action: #selector(onNewObject), for: .touchUpInside)
        view.clearObjButton.addTarget(self, action: #selector(onClearObject), for: .touchUpInside)
        view.vmIncButton.addTarget(self, action: #selector(onVMInc), for: .touchUpInside)
        view.vmDecButton.addTarget(self, action: #selector(onVMDec), for: .touchUpInside)
        view.replaceVMButton.addTarget(self, action: #selector(onReplaceVM), for: .touchUpInside)
        view.clearVMButton.addTarget(self, action: #selector(onClearVM), for: .touchUpInside)
    }

    override func onUpdate(view: UseMethodsViewable, context: ViewUpdateContext) {
        var lines = [String]()
        lines.append("[1. Equatable] counter=\(counter.value) optional=\(optionalCounter.value.map{"\($0)"} ?? "nil")")
        lines.append("[2. AnyObject] obj=\(ObjectIdentifier(selectedObject.value)) optional=\(optionalObject.value.map{"\(ObjectIdentifier($0))"} ?? "nil")")
        let df = DateFormatter(); df.dateFormat = "HH:mm:ss"
        lines.append("[3. Unconstrained] ts=\(df.string(from: timestamp.value))")
        lines.append("[6. Publisher] pub=\(publisherValue.value)")
        lines.append("[7. Sequence] seq=\(sequenceValue.value)")
        lines.append("[8. ObservableObject] vm=\(viewModel.value.label) opt=\(optionalViewModel.value?.label ?? "nil")")
        lines.append("[9. Svc+Pub] \(servicePublisherValue.value)")
        lines.append("[10. Svc+Seq] \(serviceSequenceValue.value)")
        lines.append("[11. useEffect] timer running")
        lines.append("[12. useService] check console")
        view.statusLabel.text = lines.joined(separator: "\n")
    }

    // MARK: Actions

    @objc private func onInc() {
        counter.value += 1; counterWithUpdater.value = counter.value; counterWithKeyPath.value = counter.value
    }
    @objc private func onDec() {
        counter.value -= 1; counterWithUpdater.value = counter.value; counterWithKeyPath.value = counter.value
    }
    @objc private func onSetOpt() {
        optionalCounter.value = 42; optionalWithUpdater.value = "set!"; optionalWithKeyPath.value = "set!"
    }
    @objc private func onClearOpt() {
        optionalCounter.value = nil; optionalWithUpdater.value = nil; optionalWithKeyPath.value = nil
    }
    @objc private func onNewObject() {
        selectedObject.value = NSObject(); optionalObject.value = NSObject()
    }
    @objc private func onClearObject() {
        optionalObject.value = nil
    }
    @objc private func onVMInc() {
        viewModel.value.increment(); viewModelWithUpdater.value.increment(); viewModelWithKeyPath.value.increment()
    }
    @objc private func onVMDec() {
        viewModel.value.decrement(); viewModelWithUpdater.value.decrement(); viewModelWithKeyPath.value.decrement()
    }
    @objc private func onReplaceVM() {
        let newVM = CounterViewModel(); newVM.count = 100; newVM.label = "replaced"
        viewModel.value = newVM; viewModelWithUpdater.value = CounterViewModel(); viewModelWithKeyPath.value = CounterViewModel()
        optionalViewModel.value = CounterViewModel(); optionalViewModelWithUpdater.value = CounterViewModel(); optionalViewModelWithKeyPath.value = CounterViewModel()
    }
    @objc private func onClearVM() {
        optionalViewModel.value = nil; optionalViewModelWithUpdater.value = nil; optionalViewModelWithKeyPath.value = nil
    }
}
