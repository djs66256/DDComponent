# 使用指南

## 固定视图（无复用场景）

适用于不需要重用的 UI 场景，比如详情页、信息流单条、复用视图内部。

> 📖 Demo: [01-HelloDDComponent](../../Example/DDComponent/Demos/01-HelloDDComponent/) — ViewPresenter 基础

### 1. 创建 ViewController

ViewController 需要继承 `PageViewController`：

```swift
class MyViewController: PageViewController<MyRootView, MyRootPresenter> {

    override func makeView() -> MyRootView { MyRootView() }
    override func makePresenter() -> MyRootPresenter { MyRootPresenter() }

    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
        ServiceInstaller(DataLoader.self, { MockDataLoader() })
        PresenterInstaller(lazyLoad: true, { LikePresenter() })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadData()
    }
}
```

### 2. 创建 RootPresenter

RootPresenter 负责组织和驱动整个 P-Tree。推荐使用 `typeBox`/`typeUnbox` 管理子 Presenter：

```swift
class MyRootPresenter: RootViewPresenter<MyRootPresenterView> {

    required init() {
        super.init()
        typeBox(LikePresenter())
        typeBox(SharePresenter())
    }

    override func onBindView(_ view: MyRootPresenterView) {
        super.onBindView(view)
        (typeUnbox() as LikePresenter?)?.bindView(view.likeButton)
        (typeUnbox() as SharePresenter?)?.bindView(view.shareButton)
    }
}
```

> 📖 Demo: [04-PTreeComposition](../../Example/DDComponent/Demos/04-PTreeComposition/) — P-Tree 组合

### 3. 创建 ViewPresenter

所有逻辑的承载，**View 必须定义为协议**。完整 Like 示例：

```swift
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

class LikePresenter: ViewPresenter<LikeViewProtocol> {

    struct LikeInfo { var isLiked = false; var likeCount = 0 }
    private var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        set { setState { _likeInfo = newValue } }
        get { _likeInfo }
    }

    func toggleLike() {
        guard let service = getService(LikeService.self) else { return }
        service.toggleLike(...) { [weak self] result in
            self?.likeInfo = result
            self?.notify(listener: LikeListener.self) { $0.onLikeChanged(result) }
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

## 列表视图

> 📖 Demo: [05-ListDiffUpdate](../../Example/DDComponent/Demos/05-ListDiffUpdate/) — Diff 增量更新

### 不复用 Presenter（固定列表）

当列表项固定时，构造一一对应的 Presenter 即可。适合 Cell 简单、不需要 Cell 内部 MVP 拆分的场景。

### 复用 Presenter（推荐）

Cell 需要 MVP 拆分时必须使用 `ReusableViewPresenter`：

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
        view.author = comment?.author
        view.content = comment?.text
    }
}

// Section Presenter
class CommentSectionPresenter: CollectionSectionPresenter {
    var comments: [Comment] = [] {
        didSet { setItems(comments.map { CommentItemPresenter().apply { $0.comment = $0 } }) }
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
}

// ViewController
class CommentListViewController: UITablePageViewController<CommentItemPresenter> {
    override func makePresenter() -> CommentListRootPresenter { CommentListRootPresenter() }
    override func viewDidLoad() { super.viewDidLoad(); presenter.loadComments() }
}
```

> 📖 Demo: [10-FeedExample](../../Example/DDComponent/Demos/10-FeedExample/) — 综合 Collection + Diff + 子 Presenter + Service + Notify

## Service 系统

Service 提供页面级别的可替换能力（网络、路由、埋点）：

```swift
// 注册
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, lazy: false, { DataLoaderImpl() })
}

// 获取
getService(LikeService.self)?.toggleLike(...)
```

查找链：当前 Presenter → 父 Presenter → ... → RootPresenter → 全局降级

> 📖 Demo: [02-ServiceDI](../../Example/DDComponent/Demos/02-ServiceDI/) — 完整 Service 系统

## Notify 广播系统

基于协议的多播通信，用于 Presenter 间通信：

```swift
// 定义监听协议
protocol LikeListener: AnyObject {
    func onLikeChanged(isLiked: Bool, count: Int)
}

// 发送广播
notify(listener: LikeListener.self) { $0.onLikeChanged(isLiked: true, count: 10) }

// 接收广播
extension MyPresenter: LikeListener {
    func onLikeChanged(isLiked: Bool, count: Int) { ... }
}
```

| 作用域 | 何时使用 |
|---|---|
| `.global` | 页面级事件（主题切换、全屏刷新） |
| `.children` | 父通知所有子 |
| `.parents` | 子通知父链 |
| `.reusable` | 列表 Cell 内通信 |

> 📖 Demo: [03-NotifySystem](../../Example/DDComponent/Demos/03-NotifySystem/) — 完整 Notify 系统

## Presenter 装配方式

### IdentifierViewGroupPresenter

`RootViewPresenter` 继承自它，提供 `typeBox`/`typeUnbox` 按类型存取子 Presenter：

```swift
// 注册
typeBox(LikePresenter())
typeBoxLazy({ ExpensivePresenter() })

// 获取
let like: LikePresenter? = typeUnbox()
```

### pageInstallers 声明式装配

**注意：不要在这里注册 RootPresenter，它已由 `makePresenter()` 创建。**

```swift
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    PresenterInstaller(lazyLoad: true, { LikePresenter() })  // 子 Presenter
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
}
```

## 关键规则

### ✅ DO

- **View 必须定义为协议**，不能是具体 UIView 类型
- **所有 UI 更新通过 `setState {}`**，不要直接 `view?.xxx = yyy`
- **`onBindView` 中设置回调，`onUnbindView` 中清空回调**
- **`onBindView` 中先调用 `super.onBindView(view)`**
- **子 Presenter 必须 `add(child:)` 才能加入 P-Tree**
- **异步回调中使用 `[weak self]`**

### ❌ DON'T

- **不要用 UIView 作为 View 类型**（`ViewPresenter<UIButton>` ❌）
- **不要在 `setState` 外部修改会影响 UI 的状态**
- **不要在 `pageInstallers` 中注册 RootPresenter** — `makePresenter()` 已创建
- **不要忘记在 `onUnbindView` 中清理回调**

## setState Context 速查

```swift
setState { self.count += 1 } context: {
    $0.animated = true              // 动画
    $0.invalidateLayout = true      // 布局刷新
    $0.updateViewImmediately = true // 立即更新
    $0.invalidateDataSource = true  // 列表数据源变更
    $0.invalidateContentSize = true // 仅尺寸变更
}
```

## 相关文档

- [架构设计](./architecture.md) — P-Tree/V-Tree、生命周期、UpdatePipeline
- [复用 Presenter](./reusable-presenter.md) — 列表 Cell 复用、layoutInfo、增量更新引擎
- [use* API](./use-methods.md) — 声明式状态管理
- [@PresenterState 宏](./presenter-state-macro.md) — 简化状态声明
- [Swift 6 并发模式](./swift6-patterns.md) — lazy var、MainActor
- [Demo 索引](./demo-index.md) — 所有示例 Demo
