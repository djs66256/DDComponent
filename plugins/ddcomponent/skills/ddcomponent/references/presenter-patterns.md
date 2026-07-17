# Presenter 模式详解

## 标准 Presenter（有 UI）

每个 Presenter 是一个独立的业务逻辑单元。创建 Presenter 是日常开发中最频繁的操作。

```swift
// View 协议 — 定义这个 Presenter 需要消费什么数据
protocol MyFeatureViewProtocol: AnyObject {
    var title: String { get set }
    var isLoading: Bool { get set }
    var onButtonTapped: (() -> Void)? { get set }
}

// Presenter — 业务逻辑
class MyFeaturePresenter: ViewPresenter<MyFeatureViewProtocol> {

    // 状态 — 所有影响 UI 的数据
    struct State {
        var title = ""
        var isLoading = false
    }
    private var state = State()

    // 对外暴露只读状态
    var currentTitle: String { state.title }

    // 业务方法
    func loadData() {
        setState { state.isLoading = true }
        getService(DataService.self)?.fetch { [weak self] result in
            self?.setState {
                self?.state.title = result.title
                self?.state.isLoading = false
            } context: {
                $0.animated = true
            }
        }
    }

    // 生命周期：绑定 View 时设置回调
    override func onBindView(_ view: MyFeatureViewProtocol) {
        super.onBindView(view)
        view.onButtonTapped = { [weak self] in self?.loadData() }
    }

    // 生命周期：解绑 View 时清理回调（防止循环引用）
    override func onUnbindView() {
        super.onUnbindView()
        view?.onButtonTapped = nil
    }

    // 生命周期：状态变更 → 同步到 View
    override func onUpdate(view: MyFeatureViewProtocol, context: ViewUpdateContext) {
        view.title = state.title
        view.isLoading = state.isLoading
    }
}
```

## 纯逻辑 Presenter（View = Void，无 UI）

不需要 UI，只需要能力（如埋点、生命周期监听）。View 类型设为实际需要的 Service 类型。

```swift
protocol TraceService {
    func trace(_ dict: [String: Any])
}

class LifecycleTracePresenter: ViewPresenter<TraceService>, PageLifecycle {

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        // View 就是 Service，挂载时立即绑定
        bindView(getService(TraceService.self)!)
    }

    func viewDidAppear(_ animated: Bool) {
        view?.trace(["event": "page_appear"])
    }

    func viewDidDisappear(_ animated: Bool) {
        view?.trace(["event": "page_disappear"])
    }
}
```

## 将 Presenter 装配到页面

```swift
// 方式一：在 RootPresenter 的 init 中注册（推荐）
class MyRootPresenter: RootViewPresenter<MyViewProtocol> {
    required init() {
        super.init()
        typeBox(MyFeaturePresenter())        // 常驻 Presenter
        typeBoxLazy({ ExpensivePresenter() }) // 懒加载
    }
}

// 方式二：在 pageInstallers 中注册
// ⚠️ 注册的是子 Presenter，不是 RootPresenter
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    PresenterInstaller(lazyLoad: true, { MyFeaturePresenter() })
}
```

## 文件结构建议

```
Feature/
├── Models/
│   └── Comment.swift              # 数据模型
├── Presenters/
│   ├── CommentListRootPresenter.swift
│   ├── CommentSectionPresenter.swift
│   └── CommentItemPresenter.swift
├── Views/
│   ├── CommentCell.swift           # 实现 CommentCellProtocol
│   └── CommentListView.swift       # 实现 CommentListViewProtocol
├── Protocols/
│   └── CommentViewProtocols.swift  # 所有 View 协议
├── Services/
│   ├── CommentDataService.swift    # 协议 + 实现
│   └── CommentLikeService.swift
└── CommentListViewController.swift
```

## Presenter 拆分原则

- **单一职责**：一个 Presenter 只做一件事（Like、Share、Comment 各一个）
- **独立复用**：如果某块逻辑可能在多个页面使用，就独立成 Presenter
- **独立测试**：如果某块逻辑需要单独测试，就独立成 Presenter
- **不要过度拆分**：如果两个功能总是同时出现且逻辑简单，可以放在一起

### 何时用 Service vs 直接写在 Presenter 里

- **Service**：可替换的能力（网络请求、路由跳转、埋点上报、数据持久化）
- **Presenter 内部**：无法替换的业务逻辑（状态管理、业务流程编排、UI 交互逻辑）

## 命名规范

- `XxxPresenter.swift` — 业务逻辑，继承 `ViewPresenter<XxxProtocol>`
- `XxxViewController.swift` — 页面入口，继承 `PageViewController<...>` 或 `UITablePageViewController<...>`
- `XxxService.swift` — 服务协议 + 默认实现
- View 协议可以放在 Presenter 文件顶部，也可以单独放 `Protocols/` 目录