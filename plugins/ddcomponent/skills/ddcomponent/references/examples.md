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
class CardItemPresenter: UICollectionViewFlowItemPresenter<CardCell> {
    var card: CardData? { didSet { setState {} } }

    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = true  // 默认，Cell 用 Auto Layout 约束
    }

    override func onUpdate(view: CardCell, context: ViewUpdateContext) {
        view.configure(card)
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

`UICollectionViewFlowSectionPresenter` 提供 `.header` / `.footer` 属性，比 `setSupplementary` 更简洁。Header/Footer Presenter 必须继承 `UICollectionViewFlowItemPresenter<View>`。

```swift
// Header Presenter — 必须继承 UICollectionViewFlowItemPresenter
class SectionHeaderPresenter: UICollectionViewFlowItemPresenter<SectionHeaderView> {
    var title: String = "" { didSet { setState {} } }
    var isCollapsed: Bool = false { didSet { setState {} } }
    var onTap: (() -> Void)?

    override init() {
        super.init()
        layoutInfo.calculateSizeAutomatically = false
    }

    override func onBindView(_ view: SectionHeaderView) {
        super.onBindView(view)
        view.onTap = { [weak self] in self?.onTap?() }
    }

    override func onUpdate(view: SectionHeaderView, context: ViewUpdateContext) {
        view.title = title; view.isCollapsed = isCollapsed
    }

    override func calculateSize(containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 44)
    }
}

// 使用 .header / .footer 便捷属性
let section = UICollectionViewFlowSectionPresenter()
let header = SectionHeaderPresenter()
header.title = "评论"
section.header = header   // ✅ 便捷，一行

let footer = SectionFooterPresenter(); footer.count = 10
section.footer = footer   // ✅ 便捷，一行

// ❌ BAD — 不要用 setSupplementary
section.setSupplementary("UICollectionElementKindSectionHeader", [header])
section.setSupplementary("UICollectionElementKindSectionFooter", [footer])
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