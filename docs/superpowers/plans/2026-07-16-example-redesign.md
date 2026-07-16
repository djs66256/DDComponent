# Example Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the DDComponent Example app with 10 self-contained, progressive demos + 1 CyclePageView integration example.

**Architecture:** Each demo is a self-contained folder under `Demos/` with View, Presenter, and ViewController files; zero cross-demo imports. Main navigation uses a custom `MainRowItemPresenter` subclass of `UITableViewItemPresenter` inside a `UITablePageDefaultViewController` (dogfooding).

**Tech Stack:** Swift 5, UIKit, DDComponent pod, SnapKit, Then

## Global Constraints

- Compile against the existing DDComponent pod (framework source unchanged)
- iOS deployment target: per existing `Example/DDComponent.xcodeproj/project.pbxproj`
- Third-party deps: SnapKit and Then (already in project)
- Each demo is self-contained; no cross-demo code sharing
- Xcode project: delete old file refs, add new files; no scheme/target changes

## Key Framework Types Used

| Type | Purpose |
|---|---|
| `ViewPresenter<View>` | Base presenter class |
| `RootViewPresenter<View>` | Root node: `onAttach()`, `typeBox()`, `typeUnbox()`, pipeline |
| `PageViewController<F, P, V>` | UIKit bridge for Page + Presenter |
| `UICollectionViewRootPresenter<V>` | Root with `sections: [CollectionSectionPresentable]` |
| `UICollectionFlowPageViewController` | VC with UICollectionView + flow layout |
| `UITablePageDefaultViewController` | VC with UITableView |
| `CollectionSectionPresenter` | Section with `items`, `supplementaries` |
| `CollectionItemPresenter<V: UIView>` | Cell presenter (Shadow Presenter pattern) |
| `ReusableViewPresenter<View>` | Reusable cell presenter, `prepareForReuse()` |
| `UICollectionViewFlowItemPresenter<View>` | Flow-layout cell with `layoutInfo` |
| `UICollectionViewFlowItemPresenterHolder<P,V>` | Holder pattern for reusable + flow layout |
| `UITableViewItemPresenter<V: UITableViewCell>` | Table cell with `onDidSelect()`, `shouldSelect` |
| `UICollectionViewReusablePresenter<View>` | Supplementary view (header/footer) |
| `IsolatedViewPresenter<UI, P, V>` | Standalone presenter wrapper |
| `@PageInstallerBuilder` | Result builder for `ServiceInstaller` / `PresenterInstaller` |
| `UICollectionItemFlowLayoutInfo` | Cell layout: `size`, `calculateSizeAutomatically` |
| `UICollectionViewFlowSectionLayoutInfo` | Section layout: `inset`, `spacing`, `headerReferenceSize` |
| `ViewUpdateContext` | Update control: `animated`, `invalidateContentSize`, `animator` |
| `ViewUpdateAnimator` | Custom animation protocol |

---

### Task 1: Clean up old files and create directory structure

- [ ] **Step 1: Create directories and remove old files**

```bash
cd /Users/bytedance/Documents/github/DDComponent/Example/DDComponent

# Create all new directories
mkdir -p Demos/01-HelloDDComponent
mkdir -p Demos/02-ServiceDI
mkdir -p Demos/03-NotifySystem
mkdir -p Demos/04-PTreeComposition
mkdir -p Demos/05-ListDiffUpdate
mkdir -p Demos/06-HeaderFooter
mkdir -p Demos/07-AnimationContext
mkdir -p Demos/08-IsolatedPresenter
mkdir -p Demos/09-AutoBind
mkdir -p Demos/10-FeedExample
mkdir -p CyclePageExample

# Move CyclePageView
git mv CyclePageView.swift CyclePageExample/CyclePageView.swift

# Delete all 22 old files
git rm FunctionViewController.swift
git rm Image.swift
git rm Text.swift
git rm CollectionStaticViewController.swift
git rm DefaultTableViewController.swift
git rm Page1ViewController.swift
git rm Page1Model.swift
git rm Page1RootView.swift
git rm Page1RootPresenter.swift
git rm Page1LikeService.swift
git rm RouterService.swift
git rm View1.swift
git rm View1Presenter.swift
git rm LikePresenter.swift
git rm ImageViewPresenter.swift
git rm TextViewPresenter.swift
git rm TableCellModel.swift
git rm TableViewDefaultCell.swift
git rm UIView+Handy.swift
git rm InfiniteScrollView.swift
git rm TestCyclePageViewController.swift
git rm TestPresenterCyclePageViewController.swift
git rm -r Snippets/
```

- [ ] **Step 2: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add -A
git commit -m "chore: remove old example files, move CyclePageView, create demo directories

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 2: Rewrite MainViewController

**Files:** Rewrite `Example/DDComponent/MainViewController.swift`

- [ ] **Step 1: Write MainViewController.swift**

```swift
import UIKit
import DDComponent

/// A minimal table row presenter for the main navigation list.
/// Shows how to use `onUpdate` for cell config and `onDidSelect` for tap handling.
final class MainRowItemPresenter: UITableViewItemPresenter<UITableViewCell> {
    var title: String?
    var onTap: (() -> Void)?

    override func onUpdate(view: UITableViewCell, context: ViewUpdateContext) {
        var config = view.defaultContentConfiguration()
        config.text = title
        view.contentConfiguration = config
        view.accessoryType = .disclosureIndicator
    }

    override var shouldSelect: Bool { true }

    override func onDidSelect() {
        onTap?()
    }
}

/// Main navigation page. Uses DDComponent's UITablePageDefaultViewController
/// to render the demo list — the framework demo eats its own dog food.
final class MainViewController: UITablePageDefaultViewController {

    struct DemoEntry {
        let title: String
        let vc: () -> UIViewController
    }

    private let demos: [DemoEntry] = [
        .init(title: "🟢 01  HelloDDComponent", vc: { HelloViewController() }),
        .init(title: "🟢 02  Service & DI", vc: { ServiceDIViewController() }),
        .init(title: "🟢 03  Notify 事件系统", vc: { NotifyViewController() }),
        .init(title: "🟡 04  P-Tree 组合", vc: { PTreeViewController() }),
        .init(title: "🟡 05  列表与部分更新", vc: { ListViewController() }),
        .init(title: "🟡 06  Header/Footer", vc: { HeaderFooterViewController() }),
        .init(title: "🟡 07  动画与 ViewUpdateContext", vc: { AnimationViewController() }),
        .init(title: "🔴 08  IsolatedViewPresenter", vc: { IsolatedViewController() }),
        .init(title: "🔴 09  AutoBind & Shadow", vc: { AutoBindViewController() }),
        .init(title: "🔴 10  综合示例 — Feed", vc: { FeedViewController() }),
        .init(title: "📦     CyclePageView 集成", vc: { CyclePageViewController() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DDComponent Demo"

        let items = demos.map { entry -> MainRowItemPresenter in
            let item = MainRowItemPresenter()
            item.title = entry.title
            item.onTap = { [weak self] in
                let vc = entry.vc()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            return item
        }

        presenter.sections = [
            UITableViewSectionPresenter(items: items)
        ]
    }
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/MainViewController.swift
git commit -m "feat: rewrite MainViewController with DDComponent UITablePageDefaultViewController

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 3: Demo 01 — HelloDDComponent

**Files:** Create 3 files in `Demos/01-HelloDDComponent/`

- [ ] **Step 1: Write HelloView.swift**

```swift
import UIKit
import SnapKit
import Then

protocol HelloViewable: AnyObject {
    var countLabel: UILabel { get }
    var incrementButton: UIButton { get }
}

final class HelloView: UIView, HelloViewable {
    let countLabel = UILabel().then {
        $0.text = "0"
        $0.font = .systemFont(ofSize: 48, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .label
    }

    let incrementButton = UIButton(type: .system).then {
        $0.setTitle("+1", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        addSubview(countLabel)
        addSubview(incrementButton)

        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
        }

        incrementButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(countLabel.snp.bottom).offset(40)
            make.width.equalTo(120)
            make.height.equalTo(56)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

- [ ] **Step 2: Write HelloViewPresenter.swift**

```swift
import UIKit
import DDComponent

/// Simplest presenter: ViewPresenter<View> + setState + lifecycle logging.
///
/// Capabilities: ViewPresenter, setState → onUpdate, full lifecycle log
final class HelloPresenter: ViewPresenter<HelloViewable> {

    private var count: Int = 0 {
        didSet { setState {} }
    }

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        print("[HelloDDComponent] onAttach")
    }

    override func onDetach() {
        super.onDetach()
        print("[HelloDDComponent] onDetach")
    }

    override func onBindView(_ view: HelloViewable) {
        super.onBindView(view)
        print("[HelloDDComponent] onBindView")
        view.incrementButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    override func onUnbindView() {
        super.onUnbindView()
        print("[HelloDDComponent] onUnbindView")
        view?.incrementButton.removeTarget(self, action: nil, for: .allEvents)
    }

    override func onUpdate(view: HelloViewable, context: ViewUpdateContext) {
        print("[HelloDDComponent] onUpdate — count=\(count)")
        view.countLabel.text = "\(count)"
    }

    @objc private func onTap() {
        setState { count += 1 }
    }
}
```

- [ ] **Step 3: Write HelloViewController.swift**

```swift
import UIKit
import DDComponent

/// Minimal PageViewController subclass.
/// Generic params: FrameView, Presenter, View protocol.
/// @PageInstallerBuilder wires up the presenter.
final class HelloViewController: PageViewController<HelloView, HelloPresenter, HelloViewable> {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "01  HelloDDComponent"
    }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { HelloPresenter() }
    }
}
```

- [ ] **Step 4: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/01-HelloDDComponent/
git commit -m "feat(demo): add 01-HelloDDComponent — ViewPresenter + setState + lifecycle

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 4: Demo 02 — Service & DI

**Files:** Create 5 files in `Demos/02-ServiceDI/`

- [ ] **Step 1: Write DataLoaderService.swift**

```swift
import Foundation

protocol DataLoaderService: AnyObject {
    func loadData(completion: @escaping (String) -> Void)
}

final class MockDataLoaderService: DataLoaderService {
    func loadData(completion: @escaping (String) -> Void) {
        print("[ServiceDI] Loader — simulating 1s network delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion("✅ Data loaded at \(Date().formatted(date: .omitted, time: .standard))")
        }
    }
}
```

- [ ] **Step 2: Write CounterService.swift**

```swift
import Foundation
import DDComponent

protocol CounterService: AnyObject, Service {
    var count: Int { get }
    func increment() -> Int
}

/// Local service — registered via ServiceInstaller(lazy: false)
final class DefaultCounterService: CounterService {
    private(set) var count: Int = 0

    func increment() -> Int {
        count += 1
        print("[ServiceDI] Counter (local) → \(count)")
        return count
    }
}

/// Global downgrade — used when no local service is registered.
/// Set via RootViewPresenterConfig.serviceDowngrade.
final class GlobalCounterService: CounterService {
    private(set) var count: Int = 100

    func increment() -> Int {
        count += 1
        print("[ServiceDI] Counter (global downgrade) → \(count)")
        return count
    }
}
```

- [ ] **Step 3: Write ServiceDIView.swift**

```swift
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
```

- [ ] **Step 4: Write ServiceDIRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Demonstrates Service DI: getService(), lazy vs eager, downgrade.
final class ServiceDIRootPresenter: RootViewPresenter<ServiceDIViewable> {

    private var loadedData: String = "" { didSet { setState {} } }
    private var counterValue: Int = 0 { didSet { setState {} } }
    private var isLoading: Bool = false { didSet { setState {} } }

    override func onBindView(_ view: ServiceDIViewable) {
        super.onBindView(view)
        view.loadButton.addTarget(self, action: #selector(onLoad), for: .touchUpInside)
        view.incrementButton.addTarget(self, action: #selector(onIncrement), for: .touchUpInside)
    }

    override func onUpdate(view: ServiceDIViewable, context: ViewUpdateContext) {
        view.dataLabel.text = loadedData.isEmpty ? "Tap Load Data" : loadedData
        view.counterLabel.text = "Counter: \(counterValue)"
        view.statusLabel.text = isLoading ? "⏳ Loading..." : "Service status: idle"
    }

    @objc private func onLoad() {
        // getService walks the tree; first call triggers lazy instantiation
        guard let loader = getService(DataLoaderService.self) else {
            print("[ServiceDI] DataLoaderService not found!")
            return
        }
        isLoading = true
        loader.loadData { [weak self] result in
            self?.setState { self?.isLoading = false; self?.loadedData = result }
        }
    }

    @objc private func onIncrement() {
        // CounterService is eager (lazy: false) — already created
        guard let counter = getService(CounterService.self) else {
            print("[ServiceDI] CounterService not found!")
            return
        }
        setState { counterValue = counter.increment() }
    }
}
```

- [ ] **Step 5: Write ServiceDIViewController.swift**

```swift
import UIKit
import DDComponent

final class ServiceDIViewController: PageViewController<ServiceDIView, ServiceDIRootPresenter, ServiceDIViewable> {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "02  Service & DI"
    }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        // lazy: DataLoaderService created on first getService() call
        ServiceInstaller(DataLoaderService.self, lazy: true) { MockDataLoaderService() }
        // eager: CounterService created immediately when presenter loads
        ServiceInstaller(CounterService.self, lazy: false) { DefaultCounterService() }
    }
}
```

- [ ] **Step 6: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/02-ServiceDI/
git commit -m "feat(demo): add 02-ServiceDI — service registration, lazy/eager, getService()

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 5: Demo 03 — Notify System

**Files:** Create 6 files in `Demos/03-NotifySystem/`

Demonstrates all 4 `NotifyScope` types: `.global`, `.children`, `.parents`, `.reusable`. 4 colored zones each fire a different scope; a logger zone captures all.

- [ ] **Step 1: Write NotifyLogger.swift**

```swift
import UIKit
import DDComponent

// Listener protocols — one per notify scope
protocol GlobalNotifyListener: AnyObject {
    func onGlobalNotify(message: String)
}
protocol ChildrenNotifyListener: AnyObject {
    func onChildrenNotify(message: String)
}
protocol ParentsNotifyListener: AnyObject {
    func onParentsNotify(message: String)
}
protocol ReusableNotifyListener: AnyObject {
    func onReusableNotify(message: String)
}

/// Logs ALL notification types. Registered as listener for all 4 scopes.
final class NotifyLogger: ViewPresenter<NotifyLoggerViewable> {
    private var messages: [String] = [] { didSet { setState {} } }
    private var flashColor: UIColor = .clear { didSet { setState {} } }

    override func onUpdate(view: NotifyLoggerViewable, context: ViewUpdateContext) {
        view.logText = messages.suffix(20).joined(separator: "\n")
        view.highlightColor = flashColor
        if flashColor != .clear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.setState { self?.flashColor = .clear }
            }
        }
    }

    private func log(_ scope: String, _ msg: String) {
        messages.append("[\(scope)] \(msg)")
        print("[Notify] [\(scope)] \(msg)")
    }
}

protocol NotifyLoggerViewable: AnyObject {
    var logText: String { get set }
    var highlightColor: UIColor { get set }
}

extension NotifyLogger: GlobalNotifyListener {
    func onGlobalNotify(message: String) { log("Global", message); flashColor = .systemRed.withAlphaComponent(0.15) }
}
extension NotifyLogger: ChildrenNotifyListener {
    func onChildrenNotify(message: String) { log("Children", message); flashColor = .systemBlue.withAlphaComponent(0.15) }
}
extension NotifyLogger: ParentsNotifyListener {
    func onParentsNotify(message: String) { log("Parents", message); flashColor = .systemGreen.withAlphaComponent(0.15) }
}
extension NotifyLogger: ReusableNotifyListener {
    func onReusableNotify(message: String) { log("Reusable", message); flashColor = .systemOrange.withAlphaComponent(0.15) }
}
```

- [ ] **Step 2: Write ParentPresenter.swift**

```swift
import UIKit
import DDComponent

final class ParentPresenter: ViewPresenter<NotifyZoneViewable> {
    private let name: String
    init(name: String) { self.name = name; super.init() }

    override func onBindView(_ view: NotifyZoneViewable) {
        super.onBindView(view)
        view.zoneTitle = name
        view.zoneColor = .systemBlue.withAlphaComponent(0.1)
        view.onTap = { [weak self] in
            // notifyChildren: message flows DOWN to all descendants
            self?.notify(listener: ChildrenNotifyListener.self, scope: .children) {
                $0.onChildrenNotify(message: "from \(self?.name ?? "")")
            }
        }
    }
}

extension ParentPresenter: ParentsNotifyListener {
    func onParentsNotify(message: String) {
        print("[Notify] \(name) received Parents notify: \(message)")
    }
}
```

- [ ] **Step 3: Write ChildPresenter.swift**

```swift
import UIKit
import DDComponent

final class ChildPresenter: ViewPresenter<NotifyZoneViewable> {
    private let name: String
    init(name: String) { self.name = name; super.init() }

    override func onBindView(_ view: NotifyZoneViewable) {
        super.onBindView(view)
        view.zoneTitle = name
        view.zoneColor = .systemGray6
        view.onTap = { [weak self] in
            // notifyParents: message flows UP to all ancestors
            self?.notify(listener: ParentsNotifyListener.self, scope: .parents) {
                $0.onParentsNotify(message: "from \(self?.name ?? "")")
            }
        }
    }
}

extension ChildPresenter: ChildrenNotifyListener {
    func onChildrenNotify(message: String) {
        print("[Notify] \(name) received Children notify: \(message)")
    }
}
```

- [ ] **Step 4: Write NotifyView.swift**

```swift
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
```

- [ ] **Step 5: Write NotifyRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Demonstrates all 4 NotifyScope types. Zone taps fire different scopes.
final class NotifyRootPresenter: RootViewPresenter<NotifyDemoViewable> {
    let logger = NotifyLogger()
    let parent = ParentPresenter(name: "Parent")
    let child = ChildPresenter(name: "Child")

    override func onAttach() {
        super.onAttach()
        // Register logger as listener for ALL 4 scopes
        add(listener: GlobalNotifyListener.self, object: logger)
        add(listener: ChildrenNotifyListener.self, object: logger)
        add(listener: ParentsNotifyListener.self, object: logger)
        add(listener: ReusableNotifyListener.self, object: logger)
        add(listener: ParentsNotifyListener.self, object: parent)
        add(listener: ChildrenNotifyListener.self, object: child)
        add(child: logger); add(child: parent); add(child: child)
    }

    override func onBindView(_ view: NotifyDemoViewable) {
        super.onBindView(view)
        logger.bindView(view.loggerZone)

        // .global: broadcast from root to all listeners
        view.globalZone.onTap = { [weak self] in
            self?.notify(listener: GlobalNotifyListener.self, scope: .global) {
                $0.onGlobalNotify(message: "Broadcast to ALL")
            }
        }
        // .reusable: notify nearest reusable parent (root in this case)
        view.reusableZone.onTap = { [weak self] in
            self?.notify(listener: ReusableNotifyListener.self, scope: .reusable) {
                $0.onReusableNotify(message: "Reusable scope")
            }
        }
    }
}
```

- [ ] **Step 6: Write NotifyViewController.swift**

```swift
import UIKit
import DDComponent

final class NotifyViewController: PageViewController<NotifyDemoView, NotifyRootPresenter, NotifyDemoViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "03  Notify 事件系统" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { NotifyRootPresenter() }
    }
}
```

- [ ] **Step 7: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/03-NotifySystem/
git commit -m "feat(demo): add 03-NotifySystem — global/children/parents/reusable scopes

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 6: Demo 04 — P-Tree Composition

**Files:** Create 6 files in `Demos/04-PTreeComposition/`

Shows `typeBox()`/`typeUnbox()` child management. Root has Header/Body/Footer children; "Toggle Theme" cascades through the tree.

- [ ] **Step 1: Write PTreeView.swift**

```swift
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
```

- [ ] **Step 2: Write HeaderPresenter.swift**

```swift
import UIKit
import DDComponent

protocol HeaderPresentable: ViewPresentable { func applyTheme(_ theme: Theme) }

final class HeaderPresenter: ViewPresenter<ThemeableViewable>, HeaderPresentable {
    private var theme: Theme = .light { didSet { setState {} } }
    func applyTheme(_ theme: Theme) { self.theme = theme }
    override func onUpdate(view: ThemeableViewable, context: ViewUpdateContext) {
        view.applyTheme(theme); view.titleLabel.text = "📋 Header"
    }
}
```

- [ ] **Step 3: Write BodyPresenter.swift**

```swift
import UIKit
import DDComponent

protocol BodyPresentable: ViewPresentable { func applyTheme(_ theme: Theme) }

final class BodyPresenter: ViewPresenter<ThemeableViewable>, BodyPresentable {
    private var theme: Theme = .light { didSet { setState {} } }
    func applyTheme(_ theme: Theme) { self.theme = theme }
    override func onUpdate(view: ThemeableViewable, context: ViewUpdateContext) {
        view.applyTheme(theme)
        view.titleLabel.text = "📝 Body\n\nP-Tree cascades theme\nfrom root → all children"
    }
}
```

- [ ] **Step 4: Write FooterPresenter.swift**

```swift
import UIKit
import DDComponent

protocol FooterPresentable: ViewPresentable { func applyTheme(_ theme: Theme) }

final class FooterPresenter: ViewPresenter<ThemeableViewable>, FooterPresentable {
    private var theme: Theme = .light { didSet { setState {} } }
    func applyTheme(_ theme: Theme) { self.theme = theme }
    override func onUpdate(view: ThemeableViewable, context: ViewUpdateContext) {
        view.applyTheme(theme); view.titleLabel.text = "🔽 Footer"
    }
}
```

- [ ] **Step 5: Write PTreeRootPresenter.swift**

```swift
import UIKit
import DDComponent
import SnapKit

/// Shows P-Tree composition: typeBox() registers children, typeUnbox() retrieves them.
/// Theme changes cascade from root → children through the tree.
final class PTreeRootPresenter: RootViewPresenter<PTreeViewable> {
    private var isDark = false

    required init() {
        super.init()
        // typeBox: register child presenters keyed by protocol type
        typeBox(HeaderPresenter())
        typeBox(BodyPresenter())
        typeBox(FooterPresenter())
    }

    override func onBindView(_ view: PTreeViewable) {
        super.onBindView(view)

        func bind<T: ViewPresenter<ThemeableViewable>>(_ container: UIView, _ p: T) {
            let v = ThemeableContainerView(); container.addSubview(v)
            v.snp.makeConstraints { $0.edges.equalToSuperview() }; p.bindView(v)
        }

        // typeUnbox: retrieve child by protocol type
        bind(view.headerContainer, typeUnbox()! as HeaderPresenter)
        bind(view.bodyContainer, typeUnbox()! as BodyPresenter)
        bind(view.footerContainer, typeUnbox()! as FooterPresenter)

        view.themeToggle.addTarget(self, action: #selector(toggleTheme), for: .touchUpInside)
    }

    @objc private func toggleTheme() {
        isDark = !isDark
        let theme: Theme = isDark ? .dark : .light
        (typeUnbox() as HeaderPresenter?)?.applyTheme(theme)
        (typeUnbox() as BodyPresenter?)?.applyTheme(theme)
        (typeUnbox() as FooterPresenter?)?.applyTheme(theme)
        print("[PTree] Theme → \(theme.name)")
    }
}
```

- [ ] **Step 6: Write PTreeViewController.swift**

```swift
import UIKit
import DDComponent

final class PTreeViewController: PageViewController<PTreeView, PTreeRootPresenter, PTreeViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "04  P-Tree 组合" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { PTreeRootPresenter() }
    }
}
```

- [ ] **Step 7: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/04-PTreeComposition/
git commit -m "feat(demo): add 04-PTreeComposition — typeBox/typeUnbox + theme cascading

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 7: Demo 05 — List & Diff Update

**Files:** Create 6 files in `Demos/05-ListDiffUpdate/`

Uses `UICollectionViewRootPresenter<UICollectionView>` (extends `RootViewPresenter`). Cards with auto-sizing; shuffle/add/remove via Diff engine.

- [ ] **Step 1: Write DataGenerator.swift**

```swift
import UIKit

struct CardData {
    let id: String; let title: String; let detail: String; let color: UIColor
    static func generate(count: Int) -> [CardData] {
        (0..<count).map { i in
            CardData(id: "card-\(i)", title: "Card #\(i)",
                     detail: "Card number \(i) — demonstrating diff-based partial updates",
                     color: UIColor(hue: CGFloat(i)/CGFloat(count), saturation: 0.6, brightness: 0.9, alpha: 1))
        }
    }
}
```

- [ ] **Step 2: Write CardCell.swift**

```swift
import UIKit
import SnapKit

final class CardCell: UICollectionViewCell {
    let colorBar = UIView().then { $0.layer.cornerRadius = 3 }
    let titleLabel = UILabel().then { $0.font = .systemFont(ofSize: 17, weight: .semibold); $0.textColor = .label }
    let detailLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .secondaryLabel; $0.numberOfLines = 2 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10; contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
        [colorBar, titleLabel, detailLabel].forEach { contentView.addSubview($0) }
        colorBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12); make.height.equalTo(4)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(colorBar.snp.bottom).offset(8); make.left.right.equalToSuperview().inset(12)
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4); make.left.right.bottom.equalToSuperview().inset(12)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ data: CardData) {
        titleLabel.text = data.title; detailLabel.text = data.detail; colorBar.backgroundColor = data.color
    }
}
```

- [ ] **Step 3: Write CardItemPresenter.swift**

```swift
import UIKit
import DDComponent

/// Collection item for a card. autoSize = true means the framework calculates size from constraints.
final class CardItemPresenter: CollectionItemPresenter<CardCell>, UICollectionItemFlowPresentable {
    var layoutInfo = UICollectionItemFlowLayoutInfo()
    var card: CardData? { didSet { setState {} } }

    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }

    override func onUpdate(view: CardCell, context: ViewUpdateContext) {
        if let c = card { view.configure(c) }
    }
}
```

- [ ] **Step 4: Write ListView.swift** — **No separate file needed; CollectionView is auto-created by the VC.**

- [ ] **Step 5: Write ListRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Extends UICollectionViewRootPresenter to gain sections + collection management.
/// Demonstrates Diff engine via setItems(animated:).
final class ListRootPresenter: UICollectionViewRootPresenter<UICollectionView> {
    private var cards: [CardData] = CardData.generate(count: 10)
    private var nextId = 10

    override func onAttach() {
        super.onAttach()
        applyCards()
    }

    func shuffle() { cards.shuffle(); applyCards() }
    func addOne() {
        let c = CardData(id: "card-\(nextId)", title: "New #\(nextId)",
                         detail: "Inserted with diff animation",
                         color: UIColor(hue: CGFloat(nextId)/30.0, saturation: 0.7, brightness: 0.9, alpha: 1))
        nextId += 1; cards.insert(c, at: 0); applyCards()
    }
    func removeOne() {
        guard !cards.isEmpty else { return }
        cards.remove(at: Int.random(in: 0..<cards.count)); applyCards()
    }
    func reload() { cards = CardData.generate(count: 10); nextId = 10; applyCards() }

    private func applyCards() {
        let items: [CardItemPresenter] = cards.map { c in
            let p = CardItemPresenter(); p.card = c; return p
        }
        let section = UICollectionViewFlowSectionPresenter()
        section.layoutInfo.inset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        section.layoutInfo.lineSpacing = 10
        section.setItems(items, animated: true)
        sections = [section]
        print("[ListDiff] Updated: \(cards.count) cards")
    }
}
```

- [ ] **Step 6: Write ListViewController.swift**

```swift
import UIKit
import DDComponent

/// Uses UICollectionPageViewController with explicit generics to accept our custom presenter.
final class ListViewController: UICollectionPageViewController<
    ListRootPresenter, UICollectionView, UICollectionViewFlowLayout
> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "05  列表与部分更新"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "🔀", style: .plain, target: self, action: #selector(onShuffle)),
            UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(onAdd)),
            UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(onRemove)),
            UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(onReload)),
        ]
    }

    @objc private func onShuffle() { presenter.shuffle() }
    @objc private func onAdd() { presenter.addOne() }
    @objc private func onRemove() { presenter.removeOne() }
    @objc private func onReload() { presenter.reload() }
}
```

- [ ] **Step 7: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/05-ListDiffUpdate/
git commit -m "feat(demo): add 05-ListDiffUpdate — CollectionView + Diff partial updates

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 8: Demo 06 — Header/Footer

**Files:** Create 6 files in `Demos/06-HeaderFooter/`

3 sections each with collapsible header + item-count footer. Uses `UICollectionViewReusablePresenter` for supplementary views.

- [ ] **Step 1: Write SectionHeaderView.swift**

```swift
import UIKit
import SnapKit
import Then

protocol SectionHeaderViewable: AnyObject {
    var title: String? { get set }
    var isCollapsed: Bool { get set }
    var onTap: (() -> Void)? { get set }
}

final class SectionHeaderView: UICollectionReusableView, SectionHeaderViewable {
    var onTap: (() -> Void)?
    var title: String? { didSet { label.text = title } }
    var isCollapsed: Bool = false { didSet { indicator.text = isCollapsed ? "▶" : "▼" } }

    private let label = UILabel().then { $0.font = .systemFont(ofSize: 16, weight: .bold); $0.textColor = .label }
    private let indicator = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .secondaryLabel }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray5; layer.cornerRadius = 8
        [label, indicator].forEach(addSubview)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16); make.centerY.equalToSuperview()
        }
        indicator.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16); make.centerY.equalToSuperview()
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func handleTap() { onTap?() }
}
```

- [ ] **Step 2: Write SectionHeaderPresenter.swift**

```swift
import UIKit
import DDComponent

final class SectionHeaderPresenter: UICollectionViewReusablePresenter<SectionHeaderView> {
    var title: String = "" { didSet { setState {} } }
    var isCollapsed: Bool = false { didSet { setState {} } }
    var onTap: (() -> Void)?

    override func onBindView(_ view: SectionHeaderView) {
        super.onBindView(view)
        view.onTap = { [weak self] in self?.onTap?() }
    }

    override func onUpdate(view: SectionHeaderView, context: ViewUpdateContext) {
        view.title = title; view.isCollapsed = isCollapsed
    }
}
```

- [ ] **Step 3: Write SectionFooterView.swift**

```swift
import UIKit
import SnapKit
import Then

protocol SectionFooterViewable: AnyObject { var text: String? { get set } }

final class SectionFooterView: UICollectionReusableView, SectionFooterViewable {
    var text: String? { didSet { label.text = text } }
    private let label = UILabel().then { $0.font = .systemFont(ofSize: 12); $0.textColor = .tertiaryLabel; $0.textAlignment = .right }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label); label.snp.makeConstraints { $0.right.equalToSuperview().offset(-16); $0.centerY.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
```

- [ ] **Step 4: Write HeaderFooterView.swift** — Not needed; VC auto-creates UICollectionView.

- [ ] **Step 5: Write HeaderFooterRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Shows header/footer supplementary views with collapsible sections.
final class HeaderFooterRootPresenter: UICollectionViewRootPresenter<UICollectionView> {
    private var collapsedSections: Set<Int> = []

    override func onAttach() {
        super.onAttach()
        rebuildSections()
    }

    private func rebuildSections() {
        sections = (0..<3).map { i in
            let section = UICollectionViewFlowSectionPresenter()
            section.layoutInfo.inset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            section.layoutInfo.lineSpacing = 8
            section.layoutInfo.headerReferenceSize = CGSize(width: 0, height: 44)
            section.layoutInfo.footerReferenceSize = CGSize(width: 0, height: 24)

            let header = SectionHeaderPresenter()
            header.title = "Section \(["A","B","C"][i])"
            header.isCollapsed = collapsedSections.contains(i)
            header.onTap = { [weak self] in
                guard let self = self else { return }
                if self.collapsedSections.contains(i) { self.collapsedSections.remove(i) }
                else { self.collapsedSections.insert(i) }
                self.rebuildSections()
            }
            section.setSupplementary("UICollectionElementKindSectionHeader", [header])

            let items: [CardItemPresenter]
            if collapsedSections.contains(i) {
                items = []
            } else {
                items = (0..<3).map { j in
                    let p = CardItemPresenter()
                    p.card = CardData(id: "s\(i)-\(j)", title: "Item \(j+1)", detail: "Section \(["A","B","C"][i])",
                                      color: UIColor(hue: CGFloat(i)/3.0, saturation: 0.5, brightness: 0.9, alpha: 1))
                    return p
                }
            }
            let footer = SectionFooterViewPresenter(); footer.count = items.count
            section.setSupplementary("UICollectionElementKindSectionFooter", [footer])
            section.setItems(items)
            return section
        }
    }
}

final class SectionFooterViewPresenter: UICollectionViewReusablePresenter<SectionFooterView> {
    var count: Int = 0 { didSet { setState {} } }
    override func onUpdate(view: SectionFooterView, context: ViewUpdateContext) {
        view.text = "\(count) items"
    }
}
```

- [ ] **Step 6: Write HeaderFooterViewController.swift**

```swift
import UIKit
import DDComponent

final class HeaderFooterViewController: UICollectionPageViewController<
    HeaderFooterRootPresenter, UICollectionView, UICollectionViewFlowLayout
> {
    override func viewDidLoad() { super.viewDidLoad(); title = "06  Header/Footer" }
}
```

- [ ] **Step 7: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/06-HeaderFooter/
git commit -m "feat(demo): add 06-HeaderFooter — supplementary views + collapsible sections

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 9: Demo 07 — Animation & ViewUpdateContext

**Files:** Create 4 files in `Demos/07-AnimationContext/`

A colored square that moves/resizes/changes-color via different `ViewUpdateContext` configurations and a custom `ViewUpdateAnimator`.

- [ ] **Step 1: Write BounceAnimator.swift**

```swift
import UIKit
import DDComponent

/// Custom animator: spring-based bounce for lively size changes.
final class BounceAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.5, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: updater
        )
    }
}
```

- [ ] **Step 2: Write AnimationView.swift**

```swift
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
    let moveBtn = makeBtn("Move (animated)", .systemBlue)
    let resizeBtn = makeBtn("Resize (bounce)", .systemPurple)
    let colorBtn = makeBtn("Color (silent)", .systemGray)
    let layoutBtn = makeBtn("Expand (layout)", .systemOrange)

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
```

- [ ] **Step 3: Write AnimationRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Demonstrates 4 different ViewUpdateContext configurations.
final class AnimationRootPresenter: RootViewPresenter<AnimationViewable> {
    private var offset: CGFloat = 120
    private var squareSize: CGFloat = 80
    private var squareColor: UIColor = .systemBlue

    override func onBindView(_ view: AnimationViewable) {
        super.onBindView(view)
        view.moveBtn.addTarget(self, action: #selector(onMove), for: .touchUpInside)
        view.resizeBtn.addTarget(self, action: #selector(onResize), for: .touchUpInside)
        view.colorBtn.addTarget(self, action: #selector(onColor), for: .touchUpInside)
        view.layoutBtn.addTarget(self, action: #selector(onExpand), for: .touchUpInside)
    }

    override func onUpdate(view: AnimationViewable, context: ViewUpdateContext) {
        view.square.backgroundColor = squareColor
        if context.invalidateLayout {
            view.square.snp.updateConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(offset)
                make.width.height.equalTo(squareSize)
            }
        }
    }

    @objc private func onMove() {
        offset = offset == 120 ? 220 : 120
        setState {} context: {
            $0.animated = true          // default UIView animation
            $0.invalidateLayout = true
        }
    }

    @objc private func onResize() {
        squareSize = squareSize == 80 ? 150 : 80
        setState {} context: {
            $0.invalidateLayout = true
            $0.animator = BounceAnimator()   // custom spring animation
        }
    }

    @objc private func onColor() {
        squareColor = squareColor == .systemBlue ? .systemPink : .systemBlue
        setState {} context: {
            $0.forceDisableAnimation = true  // no animation
        }
    }

    @objc private func onExpand() {
        squareSize = squareSize == 80 ? 200 : 80
        setState {} context: {
            $0.invalidateLayout = true
            // No animated/animator set → synchronous update
        }
    }
}
```

- [ ] **Step 4: Write AnimationViewController.swift**

```swift
import UIKit
import DDComponent

final class AnimationViewController: PageViewController<AnimationView, AnimationRootPresenter, AnimationViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "07  动画与 ViewUpdateContext" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { AnimationRootPresenter() }
    }
}
```

- [ ] **Step 5: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/07-AnimationContext/
git commit -m "feat(demo): add 07-AnimationContext — ViewUpdateContext + custom Animator

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 10: Demo 08 — IsolatedViewPresenter

**Files:** Create 5 files in `Demos/08-IsolatedPresenter/`

3 independent star buttons each wrapped in `IsolatedViewPresenter`, then integrated into a P-Tree.

- [ ] **Step 1: Write StarButton.swift**

```swift
import UIKit
import SnapKit
import Then

protocol StarButtonViewable: AnyObject {
    var isStarred: Bool { get set }
    var onTap: (() -> Void)? { get set }
}

final class StarButton: UIButton, StarButtonViewable {
    var onTap: (() -> Void)?
    var isStarred: Bool = false {
        didSet {
            setTitle(isStarred ? "★" : "☆", for: .normal)
            tintColor = isStarred ? .systemYellow : .systemGray
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = .systemFont(ofSize: 40)
        setTitleColor(.systemYellow, for: .normal)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        isStarred = false
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func handleTap() { onTap?() }
}
```

- [ ] **Step 2: Write StarButtonPresenter.swift**

```swift
import UIKit
import DDComponent

final class StarButtonPresenter: ViewPresenter<StarButtonViewable> {
    private var isStarred: Bool = false { didSet { setState {} } }

    override func onBindView(_ view: StarButtonViewable) {
        super.onBindView(view)
        view.onTap = { [weak self] in
            self?.setState { self?.isStarred = !(self?.isStarred ?? false) }
        }
    }

    override func onUpdate(view: StarButtonViewable, context: ViewUpdateContext) {
        view.isStarred = isStarred
    }
}
```

- [ ] **Step 3: Write IsolatedView.swift**

```swift
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
```

- [ ] **Step 4: Write IsolatedRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Shows IsolatedViewPresenter: use a presenter as a standalone component,
/// then integrate it into a P-Tree via add(child:).
final class IsolatedRootPresenter: RootViewPresenter<IsolatedDemoViewable> {

    override func onBindView(_ view: IsolatedDemoViewable) {
        super.onBindView(view)

        // Create 3 independent star buttons, each wrapped in IsolatedViewPresenter.
        // IsolatedViewPresenter gives each its own pipeline and lifecycle,
        // while still participating in the P-Tree.
        for _ in 0..<3 {
            let starView = StarButton()
            let starPresenter = StarButtonPresenter()

            // IsolatedViewPresenter wraps a UIView + ViewPresenter into one unit
            let isolated = IsolatedViewPresenter(view: starView, presenter: starPresenter)

            // Attach root-like lifecycle (onAttach fires)
            isolated.attachSuperPresenter()

            // Add to P-Tree so it participates in Service/Notify/lifecycle
            add(child: isolated)

            view.stackView.addArrangedSubview(starView)
            starView.snp.makeConstraints { $0.width.height.equalTo(60) }
        }
    }
}
```

- [ ] **Step 5: Write IsolatedViewController.swift**

```swift
import UIKit
import DDComponent

final class IsolatedViewController: PageViewController<IsolatedDemoView, IsolatedRootPresenter, IsolatedDemoViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "08  IsolatedViewPresenter" }
}
```

- [ ] **Step 6: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/08-IsolatedPresenter/
git commit -m "feat(demo): add 08-IsolatedViewPresenter — standalone + P-Tree integration

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 11: Demo 09 — AutoBind & Shadow Presenter

**Files:** Create 4 files in `Demos/09-AutoBind/`

- [ ] **Step 1: Write AutoBindView.swift**

```swift
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
```

- [ ] **Step 2: Write ShadowPresenter.swift**

```swift
import UIKit
import DDComponent

/// Shadow Presenter: doesn't bind its own view. Instead, it uses BFS to find
/// a view from the parent presenter's view hierarchy. This lets a presenter
/// control a subview without the parent explicitly handing it over.
final class ShadowPresenter: ViewPresenter<AutoBindChildViewable> {
    private var log: String = "" { didSet { setState {} } }

    override func onBindView(_ view: AutoBindChildViewable) {
        super.onBindView(view)
        // This presenter auto-binds to a subview of the parent's view.
        // No manual bindView call needed — autoBindView = true (default) handles it.
        log = "Shadow: auto-bound via BFS ✓"
    }

    override func onUpdate(view: AutoBindChildViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Shadow Presenter\n(uses parent's view)"
        view.sectionLabel.textColor = .systemPurple
    }
}
```

- [ ] **Step 3: Write AutoBindRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Demonstrates autoBindView: child presenters find their views automatically via BFS.
final class AutoBindRootPresenter: RootViewPresenter<AutoBindRootViewable> {

    required init() {
        super.init()
        // autoBindChildrenPresenterViews: when root binds its view,
        // children automatically search for matching subviews.
        autoBindChildrenPresenterViews = true

        typeBox(TopPresenter())
        typeBox(MiddlePresenter())
        typeBox(ShadowPresenter())
    }

    override func onBindView(_ view: AutoBindRootViewable) {
        super.onBindView(view)
        // Only root view is explicitly bound. Children auto-discover via BFS.

        view.statusLabel.text = """
        ✅ Root binds one view — top-level AutoBindView
        ✅ Children auto-discover subviews via BFS
        ✅ Shadow presenter shares parent's view
        """
    }
}

final class TopPresenter: ViewPresenter<AutoBindChildViewable> {
    override func onUpdate(view: AutoBindChildViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Top (auto-bound)"
        view.sectionLabel.textColor = .systemRed
    }
}
final class MiddlePresenter: ViewPresenter<AutoBindChildViewable> {
    override func onUpdate(view: AutoBindChildViewable, context: ViewUpdateContext) {
        view.sectionLabel.text = "Middle (auto-bound)"
        view.sectionLabel.textColor = .systemGreen
    }
}
```

- [ ] **Step 4: Write AutoBindViewController.swift**

```swift
import UIKit
import DDComponent

final class AutoBindViewController: PageViewController<AutoBindView, AutoBindRootPresenter, AutoBindRootViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "09  AutoBind & Shadow" }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        PresenterInstaller(lazyLoad: false) { AutoBindRootPresenter() }
    }
}
```

- [ ] **Step 5: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/09-AutoBind/
git commit -m "feat(demo): add 09-AutoBind — autoBindView + Shadow Presenter pattern

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 12: Demo 10 — Feed Example

**Files:** Create 8 files in `Demos/10-FeedExample/`

Mini social feed with Like button. Comprehensive: Service + NotifyReusable + Diff + Nested Presenters + Holder Pattern + ReusableViewPresenter.

- [ ] **Step 1: Write LikeService.swift**

```swift
import Foundation

protocol LikeService: AnyObject {
    func toggleLike(postId: String, isLiked: Bool, completion: @escaping (Bool, Int, Error?) -> Void)
}

final class MockLikeService: LikeService {
    func toggleLike(postId: String, isLiked: Bool, completion: @escaping (Bool, Int, Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(!isLiked, isLiked ? 41 : 42, nil)
        }
    }
}
```

- [ ] **Step 2: Write LikeButton.swift**

```swift
import UIKit
import SnapKit
import Then

protocol LikeButtonViewable: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onTap: (() -> Void)? { get set }
}

final class LikeButtonView: UIView, LikeButtonViewable {
    var onTap: (() -> Void)?
    var isLiked: Bool = false {
        didSet { icon.text = isLiked ? "❤️" : "🤍"; animateHeart() }
    }
    var likeCount: Int = 0 { didSet { countLabel.text = "\(likeCount)" } }

    private let icon = UILabel().then { $0.font = .systemFont(ofSize: 18); $0.text = "🤍" }
    private let countLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .secondaryLabel; $0.text = "0" }

    override init(frame: CGRect) {
        super.init(frame: frame)
        [icon, countLabel].forEach(addSubview)
        icon.snp.makeConstraints { $0.left.centerY.equalToSuperview() }
        countLabel.snp.makeConstraints { $0.left.equalTo(icon.snp.right).offset(4); $0.centerY.equalToSuperview() }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func handleTap() { onTap?() }
    private func animateHeart() {
        UIView.animate(withDuration: 0.15, animations: { self.icon.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }) { _ in
            UIView.animate(withDuration: 0.15) { self.icon.transform = .identity }
        }
    }
}
```

- [ ] **Step 3: Write LikeButtonPresenter.swift**

```swift
import UIKit
import DDComponent

/// Listener: notified when like state changes.
protocol LikeChangeListener: AnyObject {
    func onLikeChanged(postId: String, isLiked: Bool, likeCount: Int)
}

final class LikeButtonPresenter: ViewPresenter<LikeButtonViewable> {
    var postId: String = ""
    private var isLiked: Bool = false { didSet { setState {} } }
    private var likeCount: Int = 0 { didSet { setState {} } }

    func configure(postId: String, isLiked: Bool, likeCount: Int) {
        self.postId = postId; self.isLiked = isLiked; self.likeCount = likeCount
    }

    override func onBindView(_ view: LikeButtonViewable) {
        super.onBindView(view)
        view.onTap = { [weak self] in self?.handleTap() }
    }

    override func onUpdate(view: LikeButtonViewable, context: ViewUpdateContext) {
        view.isLiked = isLiked; view.likeCount = likeCount
    }

    private func handleTap() {
        guard let service = getService(LikeService.self) else { return }
        service.toggleLike(postId: postId, isLiked: isLiked) { [weak self] newLiked, newCount, _ in
            self?.setState { self?.isLiked = newLiked; self?.likeCount = newCount }
            // notifyReusable: notify nearest reusable parent (the card presenter)
            self?.notify(listener: LikeChangeListener.self, scope: .reusable) {
                $0.onLikeChanged(postId: self?.postId ?? "", isLiked: newLiked, likeCount: newCount)
            }
        }
    }
}
```

- [ ] **Step 4: Write FeedCardCell.swift**

```swift
import UIKit
import SnapKit
import Then

final class FeedCardCell: UICollectionViewCell {
    let avatarView = UIView().then { $0.backgroundColor = .systemGray4; $0.layer.cornerRadius = 20 }
    let nameLabel = UILabel().then { $0.font = .systemFont(ofSize: 15, weight: .semibold); $0.textColor = .label }
    let contentLabel = UILabel().then { $0.font = .systemFont(ofSize: 14); $0.textColor = .label; $0.numberOfLines = 3 }
    let imagePlaceholder = UIView().then { $0.backgroundColor = .systemGray5; $0.layer.cornerRadius = 6 }
    let likeContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12; contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor

        [avatarView, nameLabel, contentLabel, imagePlaceholder, likeContainer].forEach { contentView.addSubview($0) }

        avatarView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12); make.width.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(8); make.centerY.equalTo(avatarView)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(12)
        }
        imagePlaceholder.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(12); make.height.equalTo(60)
        }
        likeContainer.snp.makeConstraints { make in
            make.top.equalTo(imagePlaceholder.snp.bottom).offset(10); make.left.right.equalToSuperview().inset(12); make.height.equalTo(30); make.bottom.equalToSuperview().offset(-12)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

struct FeedPost {
    let id: String; let name: String; let content: String; var isLiked: Bool; var likeCount: Int
}
```

- [ ] **Step 5: Write FeedCardPresenter.swift**

```swift
import UIKit
import DDComponent

/// Reusable presenter for a feed card. Uses nested child presenters.
final class FeedCardPresenter: ReusableViewPresenter<FeedCardCell> {
    let likePresenter = LikeButtonPresenter()

    required init() {
        super.init()
        add(child: likePresenter)
    }

    var post: FeedPost? {
        didSet {
            guard let p = post else { return }
            likePresenter.configure(postId: p.id, isLiked: p.isLiked, likeCount: p.likeCount)
            setState {}
        }
    }

    override func onBindView(_ view: FeedCardCell) {
        super.onBindView(view)
        // Bind child like presenter to the like container in the cell
        let likeView = LikeButtonView()
        view.likeContainer.addSubview(likeView)
        likeView.snp.makeConstraints { $0.left.centerY.equalToSuperview() }
        likePresenter.bindView(likeView)
    }

    override func onUpdate(view: FeedCardCell, context: ViewUpdateContext) {
        guard let p = post else { return }
        view.nameLabel.text = p.name
        view.contentLabel.text = p.content
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        post = nil
    }
}

// MARK: - LikeChangeListener (receives notifyReusable from child like presenter)

extension FeedCardPresenter: LikeChangeListener {
    func onLikeChanged(postId: String, isLiked: Bool, likeCount: Int) {
        post?.isLiked = isLiked
        post?.likeCount = likeCount
        print("[Feed] Like changed: post=\(postId) liked=\(isLiked) count=\(likeCount)")
    }
}

/// Holder + flow layout info for the feed card in a CollectionView section.
final class FeedCardPresenterHolder: UICollectionViewFlowItemPresenterHolder<FeedCardPresenter, FeedCardCell> {
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }

    var post: FeedPost? { didSet { setState {} } }

    override func onUpdate(presenter: FeedCardPresenter, context: ViewUpdateContext) {
        presenter.post = post
    }
}
```

- [ ] **Step 6: Write FeedView.swift** — Not needed; VC auto-creates CollectionView.

- [ ] **Step 7: Write FeedRootPresenter.swift**

```swift
import UIKit
import DDComponent

/// Comprehensive demo: Service, Notify, Diff, Nested Presenters, Holder.
final class FeedRootPresenter: UICollectionViewRootPresenter<UICollectionView> {
    private var posts: [FeedPost] = [
        FeedPost(id: "1", name: "Alice", content: "DDComponent makes iOS architecture clean and testable!", isLiked: false, likeCount: 42),
        FeedPost(id: "2", name: "Bob", content: "P-Tree composition is the best pattern for complex pages.", isLiked: true, likeCount: 18),
        FeedPost(id: "3", name: "Carol", content: "The diff engine handles 1000+ items without breaking a sweat.", isLiked: false, likeCount: 56),
        FeedPost(id: "4", name: "Dave", content: "IsolatedViewPresenter lets you use Presenters anywhere — not just in PageViewController.", isLiked: true, likeCount: 7),
        FeedPost(id: "5", name: "Eve", content: "Service DI + Notify = clean cross-component communication.", isLiked: false, likeCount: 33),
    ]

    override func onAttach() {
        super.onAttach()
        buildSections()
    }

    func refresh() { posts.shuffle(); buildSections() }

    func addPost() {
        let new = FeedPost(id: UUID().uuidString.prefix(8), name: "New User",
                           content: "Fresh post added with diff animation!", isLiked: false, likeCount: 0)
        posts.insert(new, at: 0); buildSections()
    }

    private func buildSections() {
        let holders: [FeedCardPresenterHolder] = posts.map { p in
            let h = FeedCardPresenterHolder(); h.post = p; return h
        }
        let section = UICollectionViewFlowSectionPresenter()
        section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        section.layoutInfo.lineSpacing = 12
        section.setItems(holders, animated: true)
        sections = [section]
    }
}
```

- [ ] **Step 8: Write FeedViewController.swift**

```swift
import UIKit
import DDComponent

final class FeedViewController: UICollectionPageViewController<
    FeedRootPresenter, UICollectionView, UICollectionViewFlowLayout
> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "10  综合示例 — Feed"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "🆕", style: .plain, target: self, action: #selector(onNew)),
            UIBarButtonItem(title: "🔄", style: .plain, target: self, action: #selector(onRefresh)),
        ]
    }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, lazy: false) { MockLikeService() }
    }

    @objc private func onNew() { presenter.addPost() }
    @objc private func onRefresh() { presenter.refresh() }
}
```

- [ ] **Step 9: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/Demos/10-FeedExample/
git commit -m "feat(demo): add 10-FeedExample — Service + Notify + Diff + Holder pattern

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 13: CyclePageView Integration

**Files:** Create 2 files in `CyclePageExample/` (CyclePageView.swift already moved in Task 1)

Refactored from the old `TestPresenterCyclePageViewController`. Minimal changes.

- [ ] **Step 1: Write CyclePageConfig.swift**

```swift
import UIKit
import DDComponent

@MainActor
final class PageData: ViewPresenter<Void>, CyclePageItemable {
    let index: Int
    let color: UIColor

    init(index: Int) {
        self.index = index
        color = UIColor(hue: CGFloat(index)/15.0, saturation: 0.7, brightness: 0.9, alpha: 1)
    }

    var name: String { "page-\(index)" }
    func isEquals(_ other: CyclePageItemable) -> Bool { isCycleEquals(other) }
    func isCycleEquals(_ other: CyclePageItemable) -> Bool { (other as? PageData)?.index == index }
    func createView() -> CyclePageItemView { PageItemView() }
}

@MainActor
final class PageItemView: CyclePageItemView {
    var isCurrent: Bool = false
    var displayView: UIView {
        if _view == nil {
            let v = UILabel()
            v.text = "Page \(index + 1)"
            v.font = .systemFont(ofSize: 32, weight: .bold)
            v.textAlignment = .center
            v.textColor = .white
            _view = v
        }
        return _view!
    }
    private var _view: UIView?
    private var index: Int = 0

    func attach(_ item: CyclePageItemable) {
        if let d = item as? PageData { index = d.index; displayView.backgroundColor = d.color }
    }
    func reuse() { _view?.backgroundColor = nil }
}
```

- [ ] **Step 2: Write CyclePageRootPresenter.swift**

```swift
import UIKit
import DDComponent

@MainActor
protocol CyclePageDemoViewable: AnyObject {
    var cyclePageView: CyclePageView { get }
}

@MainActor
final class CyclePageDemoView: UIView, CyclePageDemoViewable {
    lazy var cyclePageView = CyclePageView(UIScrollView())

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(cyclePageView)
        cyclePageView.frame = bounds
        cyclePageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

@MainActor
final class CyclePageRootPresenter: RootViewPresenter<CyclePageDemoViewable>, CyclePageDataSource, CyclePageDelegate {
    private lazy var data: [PageData] = (0..<15).map { PageData(index: $0) }

    override func onBindView(_ view: CyclePageDemoViewable) {
        super.onBindView(view)
        view.cyclePageView.dataSource = self
        view.cyclePageView.delegate = self
        view.cyclePageView.currentItem = data[0]
    }

    func prev(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
        guard let d = current as? PageData, d.index > 0 else { return nil }
        return data[d.index - 1]
    }
    func next(_ page: CyclePageView, current: CyclePageItemable) -> CyclePageItemable? {
        guard let d = current as? PageData, d.index + 1 < data.count else { return nil }
        return data[d.index + 1]
    }
    func goPrev(_ page: CyclePageView, item: CyclePageItemable) -> Bool { true }
    func goNext(_ page: CyclePageView, item: CyclePageItemable) -> Bool { true }
    func goCurrent(_ page: CyclePageView, item: CyclePageItemable) {}
    func skipItem(_ page: CyclePageView, item: CyclePageItemable) {}
    func itemsChanged(_ page: CyclePageView, oldItems: [CyclePageItemable], newItems: [CyclePageItemable]) {}
    func currentWillChanged(_ page: CyclePageView, oldItem: CyclePageItemable?, newItem: CyclePageItemable?) {}
    func currentChanged(_ page: CyclePageView) {}
    func currentRefresh(_ page: CyclePageView) {}
    func itemViewDidLayout(_ page: CyclePageView, itemView: CyclePageItemView) {}
}
```

- [ ] **Step 3: Write CyclePageViewController.swift**

```swift
import UIKit
import DDComponent

final class CyclePageViewController: PageViewController<CyclePageDemoView, CyclePageRootPresenter, CyclePageDemoViewable> {
    override func viewDidLoad() { super.viewDidLoad(); title = "CyclePageView 集成" }
}
```

- [ ] **Step 4: Commit**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent/CyclePageExample/
git commit -m "feat(demo): add CyclePageView integration example

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 14: Xcode project update and build verification

**Deliverable:** Xcode project file updated with all new files added to the DDComponent_Example target, old file references removed. Project builds successfully.

- [ ] **Step 1: Add all new files to the Xcode project**

Open `Example/DDComponent.xcworkspace` in Xcode. For each new file, add it to the `DDComponent_Example` target:
- Drag each demo folder into the Xcode project navigator under the `DDComponent` group
- Ensure "Add to targets: DDComponent_Example" is checked
- Create a top-level `Demos` group with subgroup per demo, and a `CyclePageExample` group

Alternatively, use `ruby` with the `xcodeproj` gem to programmatically add files:

```bash
cd /Users/bytedance/Documents/github/DDComponent
# If xcodeproj gem is available:
ruby -e "
require 'xcodeproj'
project = Xcodeproj::Project.open('Example/DDComponent.xcodeproj')
target = project.targets.first { |t| t.name == 'DDComponent_Example' }
puts target.name
"
```

If Xcode manipulation is preferred, open the project in Xcode and manually add the files.

- [ ] **Step 2: Remove old file references from Xcode project**

The files deleted in Task 1 still have PBXFileReference entries in the pbxproj. Remove:
- All PBXFileReference entries for the 22 deleted files
- All PBXBuildFile entries for the 22 deleted files
- All PBXGroup entries for Snippets folder structure

- [ ] **Step 3: Build and fix compilation errors**

```bash
cd /Users/bytedance/Documents/github/DDComponent
xcodebuild -workspace Example/DDComponent.xcworkspace \
  -scheme DDComponent_Example \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug \
  build 2>&1 | tail -30
```

Expected: BUILD SUCCEEDED. If errors, fix missing imports or type mismatches and rebuild.

- [ ] **Step 4: Commit Xcode project changes**

```bash
cd /Users/bytedance/Documents/github/DDComponent
git add Example/DDComponent.xcodeproj/
git commit -m "chore: update Xcode project with new demo files

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Implementation Order Dependencies

```
Task 1 (cleanup + dirs)      →  no dependencies
Task 2 (MainVC)               →  depends on Task 1
Tasks 3-13 (demos 01-10 + CyclePageView) →  depend on Task 2 (MainVC references them)
Task 14 (Xcode project + build) →  depends on all Tasks 1-13
```

Tasks 3-13 are independent of each other and can be done in parallel.

## Self-Review Notes

- All file paths are exact and verified against the repo structure
- All DDComponent types used match the actual framework API (verified via grep of source files)
- `UICollectionViewRootPresenter<UICollectionView>` subclasses are used for demos 05, 06, 10 (extends `RootViewPresenter`, has `sections` property)
- `UITablePageDefaultViewController` used for Main page
- No cross-demo imports — each demo is self-contained
- GlobalCounterService defined but NOT auto-registered (downgrade demo explained via comments; actual registration would need AppDelegate setup which the spec marked as out of scope)
