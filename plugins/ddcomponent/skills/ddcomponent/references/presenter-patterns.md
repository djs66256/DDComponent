# Presenter 模式详解

每个 Presenter 是一个独立的业务逻辑单元。

## 标准 Presenter（有 UI）

```swift
protocol MyFeatureViewProtocol: AnyObject {
    var title: String { get set }
    var isLoading: Bool { get set }
    var onButtonTapped: (() -> Void)? { get set }
}

class MyFeaturePresenter: ViewPresenter<MyFeatureViewProtocol> {

    struct State {
        var title = ""
        var isLoading = false
    }
    private var state = State()

    var currentTitle: String { state.title }

    func loadData() {
        setState { state.isLoading = true }
        getService(DataService.self)?.fetch { [weak self] result in
            self?.setState {
                self?.state.title = result.title
                self?.state.isLoading = false
            } context: { $0.animated = true }
        }
    }

    override func onBindView(_ view: MyFeatureViewProtocol) {
        super.onBindView(view)
        view.onButtonTapped = { [weak self] in self?.loadData() }
    }

    override func onUnbindView() {
        super.onUnbindView()
        view?.onButtonTapped = nil
    }

    override func onUpdate(view: MyFeatureViewProtocol, context: ViewUpdateContext) {
        view.title = state.title
        view.isLoading = state.isLoading
    }
}
```

## 纯逻辑 Presenter（无 UI）

不需要 UI，只需要能力（如埋点、生命周期监听）。View 类型设为实际需要的 Service 类型。

```swift
class LifecycleTracePresenter: ViewPresenter<TraceService>, PageLifecycle {

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
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

## 装配到页面

```swift
// 方式一：在 RootPresenter 的 init 中注册（推荐）
class MyRootPresenter: RootViewPresenter<MyViewProtocol> {
    required init() {
        super.init()
        typeBox(MyFeaturePresenter())        // 常驻 Presenter
        typeBoxLazy({ ExpensivePresenter() }) // 懒加载
    }
}

// 方式二：在 pageInstallers 中注册子 Presenter
// ⚠️ 注册的是子 Presenter，不是 RootPresenter
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    PresenterInstaller(lazyLoad: true, { MyFeaturePresenter() })
}
```

## 拆分原则

- **单一职责**：一个 Presenter 只做一件事（Like、Share、Comment 各一个）
- **独立复用**：如果某块逻辑可能在多个页面使用，就独立成 Presenter
- **独立测试**：如果某块逻辑需要单独测试，就独立成 Presenter
- **不要过度拆分**：如果两个功能总是同时出现且逻辑简单，可以放在一起

## 何时用 Service vs 直接写在 Presenter 里

- **Service**：可替换的能力（网络请求、路由跳转、埋点上报、数据持久化）
- **Presenter 内部**：无法替换的业务逻辑（状态管理、业务流程编排、UI 交互逻辑）