# DDComponent 完整示例参考

这些是完整、可独立运行的端到端示例。代码可以直接复制粘贴使用。

> 💡 各主题的详细说明见对应 reference：
> - 页面模板 → `page-templates.md`
> - Presenter 模式 → `presenter-patterns.md`
> - 通信方式 → `communication.md`
> - setState 机制 → `setstate-guide.md`

## 示例 1：Like 功能（固定视图）

完整展示 View 协议、Presenter、Service、Notify 的配合。

```swift
import DDComponent

// MARK: - 数据模型
protocol LikableResourceProtocol { var id: String { get } }

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

// MARK: - 监听协议
protocol LikePresenterListener: AnyObject {
    func onLikeInfoChanged(presenter: LikePresenter, isLiked: Bool, likeCount: Int)
}

// MARK: - Presenter
class LikePresenter: ViewPresenter<LikeViewProtocol> {

    var resource: LikableResourceProtocol?

    struct LikeInfo { var isLiked: Bool = false; var likeCount: Int = 0 }

    private var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        set { setState { _likeInfo = newValue } context: { $0.animated = false } }
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

// MARK: - 装配到父 Presenter
class SuperPresenter: ViewPresenter<SuperViewProtocol> {
    let likePresenter = LikePresenter()

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        add(child: likePresenter)
    }

    override func onBindView(_ view: SuperViewProtocol) {
        super.onBindView(view)
        likePresenter.bindView(view.likeButton)
    }

    override func onUnbindView() {
        super.onUnbindView()
        likePresenter.unbindView()
    }
}
```

> 📖 Demo: [01-HelloDDComponent](../../../../Example/DDComponent/Demos/01-HelloDDComponent/)

## 示例 2：纯逻辑 Presenter（View = Void）

```swift
protocol TraceService { func trace(_ dict: [String: Any]) }

class LifecycleTracePresenter: ViewPresenter<TraceService>, PageLifecycle {
    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        bindView(getService(TraceService.self)!)
    }
    func viewDidDisappear(_ animated: Bool) { view?.trace(["event": "page_disappear"]) }
}
```

## 示例 3：UITableView 列表页

```swift
// Item Presenter
class CommentItemPresenter: ReusableViewPresenter<CommentCellProtocol> {
    required init() { super.init() }
    var comment: Comment? { didSet { setState {} } }

    override func prepareForReuse() { comment = nil }

    override func onBindView(_ view: CommentCellProtocol) {
        view.onAvatarTapped = { [weak self] in self?.openProfile() }
    }

    override func onUpdate(view: CommentCellProtocol, context: ViewUpdateContext) {
        view.author = comment?.author; view.content = comment?.text
    }

    private func openProfile() {
        getService(RouterService.self)?.openProfile(comment?.authorId)
    }
}

// Section
class CommentSectionPresenter: CollectionSectionPresenter {
    var comments: [Comment] = [] {
        didSet { setItems(comments.map { CommentItemPresenter().apply { $0.comment = $0 } }) }
    }
}

// Root
class CommentListRootPresenter: CollectionRootPresenter<CommentListViewProtocol> {
    let section = CommentSectionPresenter()
    override func onAttach() { super.onAttach(); add(child: section); sections = [section] }
}

// ViewController
class CommentListViewController: UITablePageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter { CommentListRootPresenter() }
    override func viewDidLoad() { super.viewDidLoad(); presenter.loadComments() }
}
```

> 📖 Demo: [05-ListDiffUpdate](../../../../Example/DDComponent/Demos/05-ListDiffUpdate/)

## 示例 4：IsolatedViewPresenter（独立组件）

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
        likeIsolated.notifyGlobal(listener: PageLifecycle.self) { $0.viewDidAppear(animated) }
    }
}
```

> 📖 Demo: [08-IsolatedPresenter](../../../../Example/DDComponent/Demos/08-IsolatedPresenter/)

## 示例 5：layoutInfo 布局配置

### CollectionView Item 自动计算

```swift
class MyItemPresenter: UICollectionViewFlowItemPresenter<MyCell> {
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = true }
}
```

### CollectionView Item 手动计算

```swift
class FixedSizeItem: UICollectionViewFlowItemPresenter<FixedCell> {
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = false }
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 60)
    }
}
```

### Section 布局

```swift
let section = UICollectionViewFlowSectionPresenter()
section.layoutInfo.inset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
section.layoutInfo.lineSpacing = 12
section.layoutInfo.columnCount = 2
section.setItems(items)
```

### Section Header/Footer 便捷 API

```swift
// Header Presenter — 必须继承 UICollectionViewFlowItemPresenter
class MyHeaderPresenter: UICollectionViewFlowItemPresenter<MyHeaderView> {
    var title: String = "" { didSet { setState {} } }
    override init() { super.init(); layoutInfo.calculateSizeAutomatically = false }
    override func onUpdate(view: MyHeaderView, context: ViewUpdateContext) { view.title = title }
    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 44)
    }
}

// 使用
let section = UICollectionViewFlowSectionPresenter()
section.header = MyHeaderPresenter()
section.footer = MyFooterPresenter()
```

> 📖 Demo: [06-HeaderFooter](../../../../Example/DDComponent/Demos/06-HeaderFooter/)

### TableView Item 配置

```swift
class MessageItem: UITableViewItemPresenter<MessageCell> {
    override init() { super.init(); layoutInfo.estimatedHeight = 80 }
}
```

## 示例 6：Service 注册

```swift
// 方式一：pageInstallers（推荐）
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, lazy: false, { DataLoaderImpl() })
    PresenterInstaller(lazyLoad: true, { LikePresenter() })
}

// 方式二：presenterDidLoad
override func presenterDidLoad() {
    super.presenterDidLoad()
    presenter.install {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    }
}
```

> 📖 Demo: [02-ServiceDI](../../../../Example/DDComponent/Demos/02-ServiceDI/)

## 示例 7：Animator 动画器

### 使用内置预设

```swift
// SpringAnimator 预设: .default, .bouncy, .gentle, .snappy
// EaseAnimator 预设: .default, .quick, .slow, .easeIn, .easeOut

setState { self.size = 150 } context: {
    $0.invalidateLayout = true
    $0.animated = true
    $0.animator = SpringAnimator.bouncy
}
```

### 自定义 Animator

```swift
class MySpringAnimator: ViewUpdateAnimator {
    func animate(with context: ViewUpdateContext, _ updater: @escaping () -> Void) {
        UIView.animate(withDuration: 0.6, delay: 0,
            usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8,
            options: [.allowUserInteraction], animations: updater)
    }
}

setState { ... } context: { $0.animated = true; $0.animator = MySpringAnimator() }
```

> 📖 Demo: [07-AnimationContext](../../../../Example/DDComponent/Demos/07-AnimationContext/)

## 示例 8：use* API 完整示例

```swift
import DDComponent
import Combine

final class UseDemoRootPresenter: RootViewPresenter<UseDemoViewProtocol> {

    // 1. 基本 useState
    lazy var counter: State<Int> = useState(0)
    lazy var optionalCounter: State<Int?> = useState(nil)

    // 2. ObservableObject
    lazy var viewModel = useState(CounterViewModel())
    lazy var optionalVM: State<CounterViewModel?> = useState(nil)

    // 3. Publisher（从 Service 懒加载）
    lazy var pubValue = useState("(waiting)",
        service: MyService.self, publisher: { $0.tickPublisher() })

    // 4. AsyncSequence
    lazy var seqValue = useState(0,
        service: MyService.self, sequence: { $0.tickSequence() })

    // 5. useEffect
    lazy var timerEffect = useEffect { [weak self] in
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.timestamp.value = Date() }
        }
        return { timer.invalidate() }
    }

    // 6. useService
    lazy var svcEffect = useService(MyService.self) { _ in
        print("service ready"); return { print("service cleanup") }
    }

    required init() {
        super.init()
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

> 📖 Demo: [11-UseMethods](../../../../Example/DDComponent/Demos/11-UseMethods/)

## 注意事项

1. **Swift 6 必须使用 `lazy var` + 显式类型** — `useState` 重载多，编译器无法推断类型
2. **Optional 类型用 `useState(nil)`** — 类型从 `State<Int?>` 声明推断
3. **Timer 闭包用 `MainActor.assumeIsolated`** — 非 MainActor 隔离的 Sendable 闭包
4. **ObservableObject 替换** — `state.value = newObject` 自动取消旧订阅、绑定新订阅
5. **useEffect 清理闭包** — return 的闭包在 `onDetachFromRoot` 时自动调用
6. **所有返回值必须存储** — `State`、`Effect`、`Updater` 必须有实例属性持有
7. **不要在生命周期方法中调用 use\*** — 只能在 `init()` 或属性初始化器中调用
8. **useUpdate 依赖必须完整** — updater 中读取的所有 State 都应声明在 `dependences` 中

→ 完整用法和关键规则见 [docs/use-methods.md](../docs/use-methods.md).