# 使用指南

## 固定视图（无复用场景）

适用于不需要重用的 UI 场景，比如：
1. 固定的视图（详情页、信息流单条）
2. 复用视图内部（对于该复用视图来说，内部是固定的）

### 1. 创建 ViewController

ViewController 需要继承 `PageViewController`，否则需要自行实现 Presenter 初始绑定操作。将服务和常驻 Presenter 的注册放置于 `presenterDidLoad` 或 `pageInstallers` 中，否则可能时机不正确。

```swift
class MyViewController: PageViewController<MyRootView, MyRootPresenter, MyRootPresenterView> {

    override func makeView() -> MyRootView {
        MyRootView()
    }

    override func makePresenter() -> MyRootPresenter {
        MyRootPresenter()
    }

    override func presenterDidLoad() {
        super.presenterDidLoad()
        // 注册 Service 和 Presenter
        presenter.install {
            PresenterInstaller(lazyLoad: true, { MyViewPresenter() })
            ServiceInstaller(DataLoaderService.self, { MyDataLoader() })
            ServiceInstaller(TraceService.self, { TraceServiceImpl() })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 触发数据加载
        if let loader = getService(DataLoaderService.self) {
            loader.refreshData()
        }
    }
}
```

### 2. 使用 `pageInstallers` 声明式装配

更推荐使用 `@PageInstallerBuilder` 声明式地注册 Presenter 和 Service：

```swift
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, { MockDataLoader() })
    ServiceInstaller(RouterService.self, { RouterServiceImpl() })
    PresenterInstaller(lazyLoad: true, { LikePresenter() })
    PresenterInstaller(lazyLoad: true, { SharePresenter() })
}
```

### 3. 创建 RootPresenter

RootPresenter 负责组织和驱动整个 P-Tree，有且只能有一个。可以重写 Root 并把业务逻辑放到 Root 中，但更建议的方式是进行细化拆分逻辑到各自的 Presenter。

```swift
protocol MyRootPresenterView {
    var likeButton: LikeViewProtocol { get }
    var shareButton: ShareViewProtocol { get }
}

class MyRootPresenter: RootViewPresenter<MyRootPresenterView> {

    required init() {
        super.init()
        // 注册子 Presenter
        typeBox(LikePresenter())
        typeBox(SharePresenter())
    }

    override func onAttach() {
        super.onAttach()
        // P-Tree 挂载后的初始化逻辑
    }

    override func onBindView(_ view: MyRootPresenterView) {
        super.onBindView(view)
        // 绑定子 Presenter 的 View
        if let likePresenter: LikePresenter = typeUnbox() {
            likePresenter.bindView(view.likeButton)
        }
        if let sharePresenter: SharePresenter = typeUnbox() {
            sharePresenter.bindView(view.shareButton)
        }
    }
}
```

### 4. 创建 ViewPresenter

ViewPresenter 是所有逻辑的承载，同时 **View 强烈建议定义为协议**。

#### Like 功能完整示例

```swift
// 数据模型
protocol LikableResourceProtocol {
    var id: String { get }
}

// 服务协议
protocol LikeService {
    func toggleLike(resource: LikableResourceProtocol,
                    isLiked: Bool,
                    likeCount: Int,
                    _ callback: (Bool, Int, Error?) -> Void)
}

// View 协议（数据消费的终点）
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    func set(isLiked: Bool, animated: Bool)
    var onLikeTapped: (() -> Void)? { get set }
}

// 监听协议（对外广播）
protocol LikePresenterListener: AnyObject {
    func onLikeInfoChanged(presenter: LikePresenter, isLiked: Bool, likeCount: Int)
}

class LikePresenter: ViewPresenter<LikeViewProtocol> {

    var resource: LikableResourceProtocol?

    struct LikeInfo {
        var isLiked: Bool = false
        var likeCount: Int = 0
    }

    private var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        set {
            // 需要触发 UI 更新，必须通过 setState
            setState { _likeInfo = newValue } context: { $0.animated = false }
        }
        get { _likeInfo }
    }

    // UI 更新 + 动效
    func set(likeInfo: LikeInfo, animated: Bool) {
        setState { _likeInfo = likeInfo } context: { $0.animated = animated }
    }

    func toggleLike() {
        guard let resource, let service = getService(LikeService.self) else { return }
        service.toggleLike(resource: resource, isLiked: likeInfo.isLiked,
                          likeCount: likeInfo.likeCount) { [weak self] isLiked, likeCount, error in
            if let error {
                // handle error
            } else {
                guard let self else { return }
                self.set(likeInfo: LikeInfo(isLiked: isLiked, likeCount: likeCount), animated: true)
                // 向外部广播 Like 变更消息
                notify(listener: LikePresenterListener.self) {
                    $0.onLikeInfoChanged(presenter: self, isLiked: isLiked, likeCount: likeCount)
                }
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
}
```

#### 装配到父 Presenter

```swift
class SuperPresenter: ViewPresenter<SuperViewProtocol> {
    let likePresenter = LikePresenter()

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        // 必须加到 children 才能形成 presenter-tree，组成完整系统
        add(child: likePresenter)
    }

    override func onBindView(_ view: SuperViewProtocol) {
        super.onBindView(view)
        // 必须在此绑定对应的 View
        likePresenter.bindView(view.likeButton)
    }

    override func onUnbindView() {
        super.onUnbindView()
        // 在此时解绑 View
        likePresenter.unbindView()
    }
}
```

`IdentifierViewGroupPresenter` 提供了更多组合的方式与功能，推荐使用 `typeBox`/`typeUnbox` 系列方法管理子 Presenter。

## 列表视图

### 不复用 Presenter（固定列表）

当为固定列表时，不需要考虑复用。固定列表和固定视图使用方式一致，只需要构造一一对应的 Presenter 即可：

```swift
class ListItemView: UIView { ... }

class ListItemPresenter: ViewPresenter<ListItemView> { ... }

class RootView {
    let listItemViews: [ListItemView]
}

class RootPresenter: ViewPresenter<RootView> {
    var listPresenters: [ListItemPresenter]

    override func onBindView(_ view: RootView) {
        for i in 0..<view.listItemViews.count {
            listPresenters[i].bindView(view.listItemViews[i])
        }
    }
}
```

### 复用 Presenter（推荐）

如果 Cell 不准备采用 MVP，而是一个简单的 View，则可以采用不复用 Presenter 的形式。但这种选型只能是 Cell 比较简单的场景，一旦这样选型，Cell 内部则无法进行继续 MVP 拆分。

对于需要 Cell 复用的列表，DDComponent 提供了完整的 `CollectionPresenter` 体系：

```
CollectionRootPresenter
  └── CollectionSectionPresenter  (section)
       └── CollectionItemPresenter  (cell/item)
```

可复用 Presenter 必须继承 `ReusableViewPresenter`，并需要与数据源绑定才可以展示。数据源也采用 Presenter 进行包装，从而形成完整的体系。

## Service 系统

### 设计背景

有很多能力属于提供一定功能，而非业务自身的逻辑，比如埋点、页面跳转等。这些功能又无法定义为全局能力，因为需要页面相关信息进行填补。

Service 提供**页面级别的组件化服务功能**，该能力只会在单一页面内部生效。

### 注册 Service

```swift
// 方式一：在 pageInstallers 中声明
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, lazy: false, { DataLoaderImpl() })
}

// 方式二：在 presenterDidLoad 中手动注册
override func presenterDidLoad() {
    super.presenterDidLoad()
    register(service: LikeService.self) { LikeServiceImpl() }
}
```

### 注入 NotifiableService

Service 可以实现 `NotifiableService` 协议，从而获得广播能力：

```swift
class MyService: NotifiableService {
    var notifier: ServiceNotifier?

    func doSomething() {
        // 向全局广播
        notifyGlobal(listener: SomeListener.self) {
            $0.onSomethingHappened()
        }
    }
}
```

### 全局降级服务

通过 `RootViewPresenterConfig.serviceDowngrade` 设置全局服务降级，当页面内找不到对应 Service 时回退到全局服务：

```swift
RootViewPresenterConfig.serviceDowngrade = GlobalServiceManager.shared
```

### 获取 Service

```swift
// 在任意 Presenter 中
if let service = getService(LikeService.self) {
    service.toggleLike(...)
}
```

Service 查找链：当前 Presenter → 父 Presenter → ... → RootPresenter → 全局降级

## Notify 广播系统

### 设计背景

页面拆分后，各个模块的通信问题会非常麻烦，所以通过广播的形式去简化消息传递。

### 发送广播

发送消息相对比较简单，但是需要判断消息接收主体应该包括哪些——是全局，还是子模块。

```swift
// 全局广播（发送给所有 P-Tree 中的 Presenter，也会发送到手动注册的接收方）
notifyGlobal(listener: LikeListener.self) {
    $0.onLikeChanged(isLiked: true, count: 10)
}

// 向下广播（只发送给子模块，递归实现）
// 在 reusable view 场景下，往往只想要通知自己模块下的所有 Presenter 进行更新操作
notifyChildren(listener: LikeListener.self) {
    $0.onLikeChanged(isLiked: true, count: 10)
}

// 向上广播（沿父链传递）
notifyParents(listener: SomeListener.self) {
    $0.onEvent()
}

// 复用范围广播（列表场景常用）
notifyReusable(listener: CellListener.self) {
    $0.onCellUpdated()
}
```

### 接收广播

想要接收某个消息，只需要继承该消息的协议即可：

```swift
extension MyPresenter: LikeListener {
    func onLikeChanged(isLiked: Bool, count: Int) {
        // 处理通知
    }
}
```

### 手动注册/移除监听

非 Presenter 对象（如 Service）想接收广播，需要手动注册：

```swift
// 注册
rootPresenter.add(listener: LikeListener.self, object: myService)

// 移除
rootPresenter.remove(listener: LikeListener.self, object: myService)
rootPresenter.removeAllListeners(of: myService)
```

## Presenter 装配方式

### 使用 IdentifierViewGroupPresenter

`IdentifierViewGroupPresenter` 提供了按类型/标识符存取子 Presenter 的能力（`typeBox`/`typeUnbox` 系列方法），`RootViewPresenter` 继承自它：

```swift
class MyRootPresenter: RootViewPresenter<MyView> {

    required init() {
        super.init()
        // 按类型注册
        typeBox(LikePresenter())
        typeBox(SharePresenter())

        // 按自定义 key 注册
        setViewPresenter("comment", CommentPresenter())
    }

    func getLikePresenter() -> LikePresenter? {
        typeUnbox()  // 按类型获取
    }

    func getCommentPresenter() -> CommentPresenter? {
        getViewPresenter("comment")  // 按 key 获取
    }
}
```

### 懒加载 Presenter

```swift
// 声明时设为 lazy
PresenterInstaller(lazyLoad: true, { ExpensivePresenter() })

// 或使用 typeBoxLazy
typeBoxLazy({ ExpensivePresenter() })

// 首次获取时才会创建
let presenter: ExpensivePresenter? = typeUnbox()
```

## View 自动绑定

当子 Presenter 的 View 类型与父 Presenter 的 View 中的子视图类型匹配时，可以自动绑定。自动绑定通过 BFS 在父 View 的子视图层级中查找匹配类型。

```swift
class AutoBindExample: ViewPresenter<MyView> {
    let likePresenter = LikePresenter()  // View = LikeViewProtocol

    override func onAttach(presenter: ViewPresentable) {
        add(child: likePresenter)
        // 如果 MyView 的子视图中有实现 LikeViewProtocol 的，
        // autoBind 会自动找到并绑定
    }
}
```

自动绑定默认开启，可通过 `autoBindView = false` 关闭。子 Presenter 自动绑定可通过 `autoBindChildrenPresenterViews = false` 关闭。

## 使用 @StateChecker 确保状态安全

```swift
class MyPresenter: ViewPresenter<MyView> {
    @StateChecker var count = 0  // 只能在 setState {} 内部修改

    func increment() {
        setState { count += 1 }  // ✅ 正确
    }

    func badIncrement() {
        count += 1  // ❌ 断言失败！MUST update state value inside of setState{} !
    }
}
```

## 使用 Effect 管理副作用

`Effect` 用于管理需要在 P-Tree 挂载/卸载时启动/停止的副作用（如定时器、监听等）：

```swift
class MyPresenter: ViewPresenter<MyView> {
    var timerEffect = Effect { [weak self] in
        let timer = Timer.scheduledTimer(...)
        return { timer.invalidate() }  // 返回取消动作
    }
}
```

Effect 会在 `onAttachToRoot` 时自动启动，在 `onDetachFromRoot` 时自动取消。

## 使用 Updater 分离更新逻辑

`Updater` 允许将视图更新逻辑从 `onUpdate` 中分离出来，便于模块化：

```swift
class MyPresenter: ViewPresenter<MyView> {
    var titleUpdater = Updater { view, context in
        view.titleLabel.text = title
    }

    var countUpdater = Updater { view, context in
        view.countLabel.text = "\(count)"
    }
}
```

Updater 会在 `onUpdate` 中自动执行，也可以通过 `cancel()` 取消。