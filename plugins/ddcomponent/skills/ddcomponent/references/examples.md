# DDComponent 完整示例参考

## 示例 1：Like 功能（固定视图）

完整的 Like 按钮功能，展示 View 协议、Presenter、Service、Notify 的完整配合。

### 文件：LikePresenter.swift

```swift
import DDComponent

// MARK: - 数据模型
protocol LikableResourceProtocol {
    var id: String { get }
}

// MARK: - Service
protocol LikeService {
    func toggleLike(resource: LikableResourceProtocol,
                    isLiked: Bool, likeCount: Int,
                    _ callback: (Bool, Int, Error?) -> Void)
}

// MARK: - View 协议
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    func set(isLiked: Bool, animated: Bool)
    var onLikeTapped: (() -> Void)? { get set }
}

// MARK: - 监听协议（对外广播）
protocol LikePresenterListener: AnyObject {
    func onLikeInfoChanged(presenter: LikePresenter, isLiked: Bool, likeCount: Int)
}

// MARK: - Presenter
class LikePresenter: ViewPresenter<LikeViewProtocol> {

    var resource: LikableResourceProtocol?

    struct LikeInfo {
        var isLiked: Bool = false
        var likeCount: Int = 0
    }

    private var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        set {
            setState { _likeInfo = newValue } context: { $0.animated = false }
        }
        get { _likeInfo }
    }

    func set(likeInfo: LikeInfo, animated: Bool) {
        setState { _likeInfo = likeInfo } context: { $0.animated = animated }
    }

    func toggleLike() {
        guard let resource, let service = getService(LikeService.self) else { return }
        service.toggleLike(resource: resource, isLiked: likeInfo.isLiked,
                          likeCount: likeInfo.likeCount) { [weak self] isLiked, likeCount, error in
            if error != nil { return }
            guard let self else { return }
            self.set(likeInfo: LikeInfo(isLiked: isLiked, likeCount: likeCount), animated: true)
            notify(listener: LikePresenterListener.self) {
                $0.onLikeInfoChanged(presenter: self, isLiked: isLiked, likeCount: likeCount)
            }
        }
    }

    override func onBindView(_ view: LikeViewProtocol) {
        super.onBindView(view)
        view.onLikeTapped = { [weak self] in self?.toggleLike() }
    }

    override func onUnbindView() {
        super.onUnbindView()
        view?.onLikeTapped = nil
    }

    override func onUpdate(view: LikeViewProtocol, context: ViewUpdateContext) {
        view.isLiked = likeInfo.isLiked
        view.likeCount = likeInfo.likeCount
    }
}
```

### 文件：SuperPresenter.swift（装配到父 Presenter）

```swift
class SuperPresenter: ViewPresenter<SuperViewProtocol> {
    let likePresenter = LikePresenter()

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        add(child: likePresenter)   // 必须加 children 才能形成 P-Tree
    }

    override func onBindView(_ view: SuperViewProtocol) {
        super.onBindView(view)
        likePresenter.bindView(view.likeButton)  // 绑定对应的 View
    }

    override func onUnbindView() {
        super.onUnbindView()
        likePresenter.unbindView()
    }
}
```

## 示例 2：纯逻辑 Presenter（View = Void）

当 Presenter 不需要 UI 时，View 类型设为 `Void`，Presenter 退化为纯逻辑单元。

```swift
protocol TraceService {
    func trace(_ dict: [String: Any])
}

class LifecycleTracePresenter: ViewPresenter<TraceService>, PageLifecycle {

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        // View 是 Service，挂载时立即绑定
        bindView(getService(TraceService.self)!)
    }

    func viewDidDisappear(_ animated: Bool) {
        view?.trace(["event": "page_disappear"])
    }
}
```

## 示例 3：UITableView 列表页

```swift
// Item Presenter
class CommentItemPresenter: ReusableViewPresenter<CommentCellProtocol> {
    required init() { super.init() }

    var comment: Comment? {
        didSet { setState {} }
    }

    override func prepareForReuse() {
        comment = nil
    }

    override func onBindView(_ view: CommentCellProtocol) {
        view.onAvatarTapped = { [weak self] in self?.openProfile() }
    }

    override func onUpdate(view: CommentCellProtocol, context: ViewUpdateContext) {
        view.author = comment?.author
        view.content = comment?.text
    }

    private func openProfile() {
        getService(RouterService.self)?.openProfile(comment?.authorId)
    }
}

// Section Presenter
class CommentSectionPresenter: CollectionSectionPresenter {
    var comments: [Comment] = [] {
        didSet {
            setItems(comments.map { comment in
                CommentItemPresenter().apply { $0.comment = comment }
            })
        }
    }
}

// Root Presenter
class CommentListRootPresenter: CollectionRootPresenter<CommentListViewProtocol> {
    let section = CommentSectionPresenter()

    override func onAttach() {
        super.onAttach()
        add(child: section)
        sections = [section]
    }

    func loadComments() {
        getService(DataLoader.self)?.fetch { [weak self] comments in
            self?.section.comments = comments
        }
    }
}

// ViewController
class CommentListViewController: UITablePageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter {
        CommentListRootPresenter()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadComments()
    }
}
```

## 示例 4：在非 DDComponent 页面中嵌入 Presenter

```swift
class LegacyViewController: UIViewController {
    let likeIsolated = IsolatedViewPresenter(LikeButton(), LikePresenter())

    override func viewDidLoad() {
        super.viewDidLoad()
        likeIsolated.register(service: LikeService.self) { LikeServiceImpl() }
        view.addSubview(likeIsolated.view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        likeIsolated.notifyGlobal(listener: PageLifecycle.self) {
            $0.viewDidAppear(animated)
        }
    }
}
```

## 示例 5：layoutInfo 布局配置

### CollectionView Item 自动计算

```swift
class MyItemPresenter: UICollectionViewFlowItemPresenter<MyCell> {
    var data: MyData? { didSet { setState {} } }

    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true  // 默认，Cell 用 Auto Layout 约束
    }

    override func onUpdate(view: MyCell, context: ViewUpdateContext) {
        view.configure(data)
    }
}
```

### CollectionView Item 手动计算

```swift
class FixedSizeItem: UICollectionViewFlowItemPresenter<FixedCell> {
    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }

    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 60)
    }
}
```

### Section 布局配置

```swift
let section = UICollectionViewFlowSectionPresenter()
section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
section.layoutInfo.lineSpacing = 12
section.layoutInfo.itemSpacing = 8
section.layoutInfo.columnCount = 2   // 两列网格
section.setItems(items)
sections = [section]
```

### Section Header/Footer 便捷 API

`UICollectionViewFlowSectionPresenter` 提供 `.header` / `.footer` 属性，比 `setSupplementary` 更简洁。Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`（或实现 `UICollectionItemFlowPresentable`）。

```swift
// Header Presenter — 必须继承 UICollectionViewFlowItemPresenter
class MyHeaderPresenter: UICollectionViewFlowItemPresenter<MyHeaderView> {
    var title: String = "" { didSet { setState {} } }

    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }

    override func onUpdate(view: MyHeaderView, context: ViewUpdateContext) {
        view.title = title
    }

    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 44)
    }
}

// 使用 .header / .footer 便捷属性
let section = UICollectionViewFlowSectionPresenter()
section.header = MyHeaderPresenter()
section.footer = MyFooterPresenter()

// ❌ BAD — 不要用 setSupplementary
section.setSupplementary("UICollectionElementKindSectionHeader", [header])
```

### TableView Item 配置

```swift
class MessageItem: UITableViewItemPresenter<MessageCell> {
    override init() {
        super.init()
        layoutInfo.estimatedHeight = 80   // 预估高度
        // calculateSizeAutomatically = true 是默认值
    }
}
```

### 非标准基类的 Item（需手动 conform 协议）

```swift
class MyCustomItem: CollectionItemPresenter<MyCell>, UICollectionItemFlowPresentable {
    var layoutInfo = UICollectionItemFlowLayoutInfo()
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }
}
```

## 示例 6：Service 注册的多种方式

```swift
// 方式一：pageInstallers（推荐）
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, lazy: false, { DataLoaderImpl() })
    PresenterInstaller(lazyLoad: true, { LikePresenter() })
    PresenterInstaller(lazyLoad: true, { SharePresenter() })
}

// 方式二：presenterDidLoad 中手动注册
override func presenterDidLoad() {
    super.presenterDidLoad()
    presenter.install {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
        PresenterInstaller(lazyLoad: true, { LikePresenter() })
    }
}

// 方式三：直接调用 register
presenter.register(service: MyService.self) { MyServiceImpl() }
```

## 示例 7：使用内置 Animator

框架内置了 `SpringAnimator` 和 `EaseAnimator`，无需自己实现 `ViewUpdateAnimator`。

### 使用预设

```swift
// SpringAnimator 预设
SpringAnimator.default   // 通用弹簧 (0.5s, damping 0.7)
SpringAnimator.bouncy    // 弹跳效果 (0.6s, damping 0.4)
SpringAnimator.gentle    // 柔和弹簧 (0.8s, damping 0.8)
SpringAnimator.snappy    // 快速弹簧 (0.35s, damping 0.65)

// EaseAnimator 预设
EaseAnimator.default  // 标准缓入缓出 (0.3s)
EaseAnimator.quick    // 微交互 (0.15s)
EaseAnimator.slow     // 慢速过渡 (0.8s)
EaseAnimator.easeIn   // 仅缓入 (0.3s)
EaseAnimator.easeOut  // 仅缓出 (0.3s)
```

### 使用方式

```swift
// 使用预设
setState { self.size = 150 } context: {
    $0.invalidateLayout = true
    $0.animated = true
    $0.animator = SpringAnimator.bouncy
}

// 自定义参数
setState { self.color = .systemPink } context: {
    $0.animated = true
    $0.animator = EaseAnimator(duration: 0.5, delay: 0, options: [.curveEaseOut])
}
```

### 自定义 Animator（实现协议）

```swift
class MySpringAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.6, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: updater
        )
    }
}

// 使用
setState { ... } context: {
    $0.animated = true
    $0.animator = MySpringAnimator()
}
```

## 示例 8：use* API 声明式状态管理

`use*` 方法是 React Hooks 风格的声明式 API，将状态、副作用和视图更新器集中声明在初始化阶段。所有 `use*` 方法必须在 `init()` 或属性初始化器中调用。

### 8.1 useState 基本用法

```swift
import DDComponent
import Combine

class UseDemoPresenter: ViewPresenter<UseDemoViewProtocol> {

    // Equatable: 使用 == 判等，相同值不触发更新
    lazy var counter: State<Int> = useState(0)

    // AnyObject: 使用 === 判等
    lazy var selectedObject = useState(NSObject())

    // 无约束: 总是触发更新（如 Date 不是 Equatable）
    lazy var timestamp = useState(Date())

    // Optional: 类型从属性声明推断
    lazy var optionalCounter: State<Int?> = useState(nil)
    lazy var optionalName: State<String?> = useState(nil)

    required init() {
        super.init()
        // 触发 lazy 初始化
        _ = counter; _ = selectedObject; _ = timestamp
        _ = optionalCounter; _ = optionalName
    }

    override func onUpdate(view: UseDemoViewProtocol, context: ViewUpdateContext) {
        view.countLabel.text = "\(counter.value)"
        view.optionalLabel.text = optionalCounter.value.map { "\($0)" } ?? "nil"
    }
}
```

### 8.2 useState 带 updater / keyPath

```swift
// updater: 每次状态变化时执行自定义闭包，直接操作 View
lazy var counterWithUpdater = useState(0, updater: { value, view, _ in
    view.counterLabel.text = "count: \(value)"
})

// updateTo: 直接将值写入 View 的 keyPath（需要 View: AnyObject）
lazy var title = useState("Hello", updateTo: \.titleLabel.text)

// 可选类型 + updater
lazy var optionalWithUpdater = useState(nil, updater: { value, view, _ in
    view.optionalLabel.text = value ?? "nil"
})

// 可选类型 + keyPath
lazy var optionalWithKeyPath = useState(nil, updateTo: \.optionalLabel.text)
```

### 8.3 useState 订阅 Publisher

```swift
// 直接传入 Publisher
lazy var pubValue = useState("(waiting)", publisher: myPublisher)

// 从 Service 获取 Publisher（懒加载，attach to root 时解析）
lazy var svcPubValue = useState("(waiting)",
    service: MyService.self,
    publisher: { $0.tickPublisher() })

// 带 updater 的 Publisher
lazy var pubWithUpdater = useState("(waiting)",
    updater: { value, view, _ in view.label.text = value },
    publisher: myPublisher)
```

### 8.4 useState 订阅 AsyncSequence

```swift
// 直接传入 AsyncSequence
let tickStream = AsyncStream<Int> { continuation in
    Task {
        for i in 0... { continuation.yield(i); try? await Task.sleep(nanoseconds: 1_000_000_000) }
    }
}
lazy var seqValue = useState(0, sequence: tickStream)

// 从 Service 获取 AsyncSequence
lazy var svcSeqValue = useState(0,
    service: MyService.self,
    sequence: { $0.tickSequence() })
```

### 8.5 useState 观察 ObservableObject

```swift
class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var label: String = "zero"

    func increment() { count += 1; label = "\(count)" }
}

// 基本观察：objectWillChange 时自动触发 setState → onUpdate
lazy var viewModel = useState(CounterViewModel())

// 可选 ObservableObject
lazy var optionalVM: State<CounterViewModel?> = useState(nil)

// 替换对象：自动取消旧订阅，绑定新订阅
viewModel.value = CounterViewModel()   // old cancelled, new subscribed
optionalVM.value = nil                  // 取消订阅

// 带 updater
lazy var vmWithUpdater = useState(CounterViewModel(),
    updater: { value, view, _ in view.label.text = value.label })

// 带 keyPath
lazy var vmWithKeyPath = useState(CounterViewModel(),
    updateTo: \.headerViewModel)

// 在 onUpdate 中读取最新值
override func onUpdate(view: MyView, context: ViewUpdateContext) {
    view.countLabel.text = "\(viewModel.value.count)"
    view.nameLabel.text = viewModel.value.label
}
```

### 8.6 useEffect 管理副作用

```swift
// 副作用在 attach to root 时启动，detach from root 时自动调清理闭包
lazy var timerEffect = useEffect { [weak self] in
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        MainActor.assumeIsolated { self?.timestamp.value = Date() }
    }
    return { timer.invalidate() }  // detach 时自动调用
}

// 无清理的副作用
lazy var logEffect = useEffect { print("[Demo] attached to root") }
```

### 8.7 useUpdate 依赖驱动更新

```swift
// 单依赖：只有当 counter 变化时才执行
lazy var counterUpdate = useUpdate(dependences: counter) { view, context in
    view.countLabel.text = "\(counter.value)"
}

// 多依赖：任一依赖变化时执行
lazy var combinedUpdate = useUpdate(dependences: title, counter) { view, context in
    view.titleLabel.text = title.value
    view.countLabel.text = "\(counter.value)"
}
```

### 8.8 useService 懒加载 Service

```swift
// Service 在 attach to root 时才解析，避免 init 时 Service 未注册
lazy var svcEffect = useService(MyService.self) { service in
    service.startMonitoring()
    return { service.stopMonitoring() }
}
```

### 8.9 完整示例：Presenter 使用所有 use* 变体

```swift
final class UseDemoRootPresenter: RootViewPresenter<UseDemoViewProtocol> {

    // 1. 基本 useState
    lazy var counter: State<Int> = useState(0)
    lazy var optionalCounter: State<Int?> = useState(nil)

    // 2. ObservableObject
    lazy var viewModel = useState(CounterViewModel())
    lazy var optionalVM: State<CounterViewModel?> = useState(nil)

    // 3. Publisher
    lazy var pubValue = useState("(waiting)",
        service: MyService.self,
        publisher: { $0.tickPublisher() })

    // 4. AsyncSequence
    lazy var seqValue = useState(0,
        service: MyService.self,
        sequence: { $0.tickSequence() })

    // 5. useEffect
    lazy var timerEffect = useEffect { [weak self] in
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.timestamp.value = Date() }
        }
        return { timer.invalidate() }
    }

    // 6. useService
    lazy var svcEffect = useService(MyService.self) { _ in
        print("service ready")
        return { print("service cleanup") }
    }

    required init() {
        super.init()
        // 触发所有 lazy 初始化
        _ = counter; _ = optionalCounter; _ = viewModel; _ = optionalVM
        _ = pubValue; _ = seqValue; _ = timerEffect; _ = svcEffect
    }

    override func onUpdate(view: UseDemoViewProtocol, context: ViewUpdateContext) {
        view.countLabel.text = "\(counter.value)"
        view.vmLabel.text = viewModel.value.label
        view.pubLabel.text = pubValue.value
        view.seqLabel.text = "\(seqValue.value)"
    }
}
```

### 8.10 注意事项

1. **Swift 6 必须使用 `lazy var` + 显式类型**：`useState` 重载多，编译器无法推断类型
2. **Optional 类型用 `useState(nil)`**：类型从 `State<Int?>` 声明推断，不需要显式泛型参数
3. **Timer 闭包用 `MainActor.assumeIsolated`**：Timer 回调是非 MainActor 隔离的 Sendable 闭包
4. **ObservableObject 替换**：`state.value = newObject` 自动取消旧订阅、绑定新订阅
5. **useEffect 清理闭包**：return 的闭包在 `onDetachFromRoot` 时自动调用
6. **所有返回值必须存储**：`State`、`Effect`、`Updater` 必须有实例属性持有，否则立即释放
7. **不要在生命周期方法中调用 use\***：`use*` 只能在 `init()` 或属性初始化器中调用
8. **useUpdate 依赖必须完整**：updater 中读取的所有 State 都应声明在 `dependences` 中

完整演示代码见 `Example/DDComponent/Demos/11-UseMethods/` 目录。```