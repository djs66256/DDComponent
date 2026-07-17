---
name: ddcomponent
description: >
  Use this skill whenever the user asks to create a new page, list, component, or feature
  using DDComponent. Trigger on: DDComponent, ViewPresenter, PageViewController,
  RootViewPresenter, PresenterInstaller, ServiceInstaller, setState, reusable presenter,
  "create a page", "build a list", "add a component", "MVP pattern", or any mention of
  P-Tree/V-Tree. This skill guides the user from big (page) to small (single Presenter)
  through the framework's design philosophy and code patterns.
---

# DDComponent 页面拆分框架

你是一个 DDComponent 专家。帮助用户使用 DDComponent 框架构建 iOS 页面。

## 核心设计思想

在写代码之前，先理解这三个核心思想：

1. **View 是协议，不是 UIView**。View 代表"数据消费的终点"，可以是 UI 按钮，也可以是埋点服务。同一个 Presenter 可以绑定到完全不同的 View 实现（如 Resso 和 TTM 两套 UI 共享业务逻辑）。

2. **所有 UI 更新走 setState**。View 是状态机，借鉴 React/SwiftUI 思想。直接修改 View 会导致父容器无法感知、数据不一致、列表复用时状态错乱。`setState` 统一入口，由 Pipeline 批量调度 `onUpdate`。

3. **Presenter 是业务逻辑的复用单元**。一个 Presenter 只做一件事。臃肿时继续拆分。当 View 类型为实际 Service 类型时，Presenter 退化为纯逻辑单元（如埋点上报）。

## 决策树

```
用户要做什么？
├── 创建新页面
│   ├── 固定布局（详情页、信息流）→ 固定视图模式
│   └── 列表（TableView/CollectionView）→ 列表模式
├── 在现有页面加功能模块 → 创建 Presenter，装配到父 Presenter
├── 创建可复用的列表 Cell → 复用 Presenter 模式
└── 在传统 VC 中嵌入组件 → IsolatedViewPresenter
```

## 快速参考

### 生命周期顺序

```
init() → onAttach() → onAttachToRoot() → onBindView(_:) → onUpdate(view:context:) [×N] → onUnbindView() → onDetach() → onDetachFromRoot() → deinit
```

### 固定视图页面（最小骨架）

```swift
// RootPresenter
class MyRootPresenter: RootViewPresenter<MyViewProtocol> {
    required init() {
        super.init()
        typeBox(FeaturePresenter())
    }
    override func onBindView(_ view: MyViewProtocol) {
        super.onBindView(view)
        (typeUnbox() as FeaturePresenter?)?.bindView(view.featureView)
    }
}

// ViewController
class MyViewController: PageViewController<MyRootView, MyRootPresenter> {
    override func makeView() -> MyRootView { MyRootView() }
    override func makePresenter() -> MyRootPresenter { MyRootPresenter() }
    @PageInstallerBuilder override var pageInstallers: PageInstaller {
        ServiceInstaller(DataService.self, { DataServiceImpl() })
    }
}
```

📖 **完整模板见 `references/page-templates.md`**

### 列表页面（最小骨架）

```swift
// Item Presenter（可复用）
class ItemPresenter: ReusableViewPresenter<ItemCellProtocol> {
    required init() { super.init() }
    var data: Data? { didSet { setState {} } }
    override func prepareForReuse() { data = nil }
    override func onUpdate(view: ItemCellProtocol, context: ViewUpdateContext) {
        view.title = data?.title
    }
}

// Root Presenter
class ListRootPresenter: CollectionRootPresenter<ListViewProtocol> {
    let section = CollectionSectionPresenter()
    override func onAttach() {
        super.onAttach()
        add(child: section)
        sections = [section]
    }
}

// ViewController
class ListViewController: UITablePageViewController<ItemPresenter> {
    override func makePresenter() -> ListRootPresenter { ListRootPresenter() }
}
```

📖 **完整模板见 `references/page-templates.md`**

### 标准 Presenter（最小骨架）

```swift
protocol FeatureViewProtocol: AnyObject {
    var title: String { get set }
    var onTap: (() -> Void)? { get set }
}

class FeaturePresenter: ViewPresenter<FeatureViewProtocol> {
    private var title = ""

    func load() {
        setState { title = "loading..." }
        getService(DataService.self)?.fetch { [weak self] result in
            self?.setState { self?.title = result.title }
        }
    }

    override func onBindView(_ view: FeatureViewProtocol) {
        super.onBindView(view)
        view.onTap = { [weak self] in self?.load() }
    }

    override func onUnbindView() {
        super.onUnbindView()
        view?.onTap = nil
    }

    override func onUpdate(view: FeatureViewProtocol, context: ViewUpdateContext) {
        view.title = title
    }
}
```

📖 **详细模式见 `references/presenter-patterns.md`**

### 通信方式

| 场景 | 方式 | 示例 |
|---|---|---|
| 子 → 父通知 | `notify(listener:)` | `notify(listener: LikeListener.self) { $0.onLikeChanged(...) }` |
| 父 → 子广播 | `notifyChildren(listener:)` | `notifyChildren(listener: ThemeListener.self) { ... }` |
| 外部能力（网络/路由/埋点） | `getService()` | `getService(RouterService.self)?.navigate(to: ...)` |

📖 **完整通信指南见 `references/communication.md`**

### setState Context Flags

| Flag | 用途 |
|---|---|
| `animated = true` | 动画过渡（配合 `$0.animator = SpringAnimator.bouncy` 使用内置动画器） |
| `invalidateLayout = true` | 布局变化 |
| `invalidateDataSource = true` | 列表数据源变化（触发 Diff + reload） |
| `invalidateContentSize = true` | Cell 尺寸变化 |
| `updateViewImmediately = true` | 立即更新，不等批处理 |

📖 **setState 详解 + Animator 见 `references/setstate-guide.md`**

### use* API 速查

React Hooks 风格声明式 API（`ViewPresenter+Use.swift`）。所有方法在 `init()` 或属性初始化器中调用，Swift 6 使用 `lazy var` + 显式类型标注。

| 方法 | 返回类型 | 用途 |
|---|---|---|
| `useState(0)` | `State<Int>` | 响应式状态，`.value = new` 触发 `setState` |
| `useState(0, updateTo: \.label.text)` | `State<Int>` | 状态 + 直接写入 View keyPath |
| `useState(0, publisher: pub)` | `State<Int>` | 从 Combine Publisher 订阅 |
| `useState(MyViewModel())` | `State<VM>` | 观察 ObservableObject |
| `useEffect { ...; return cleanup }` | `Effect` | 生命周期绑定副作用 |
| `useUpdate(dependences: s1, s2) { ... }` | `Updater` | 依赖驱动的视图更新器 |
| `useService(S.self) { svc in ... }` | `Effect` | 懒解析 Service |

📖 **完整用法和 8 条关键规则见 [docs/use-methods.md](./docs/use-methods.md)**

## 关键规则

### ✅ DO

- **View 必须定义为协议**（`ViewPresenter<UIButton>` ❌，`ViewPresenter<MyProtocol>` ✅）
- **所有 UI 更新通过 `setState {}`**，不直接 `view?.xxx = yyy`
- **`onBindView` 中设置回调，`onUnbindView` 中清空回调**
- **`onBindView` 中先调用 `super.onBindView(view)`**
- **子 Presenter 必须 `add(child:)` 加入 P-Tree**，否则收不到生命周期
- **异步回调中使用 `[weak self]`**
- **Swift 6 下 use* 用 `lazy var` + 显式类型标注**

### ❌ DON'T

- **不用 UIView 作为 View 类型**
- **不在 `setState` 外部修改影响 UI 的状态**
- **不在 `pageInstallers` 中注册 RootPresenter** — `makePresenter()` 已创建
- **不忘记在 `onUnbindView` 中清理回调**
- **不在 `setState` 闭包内执行副作用**（网络请求、埋点等）
- **不在生命周期方法中调用 use\*** — 只能在 `init()` 或属性初始化器中调用

## Reference 文件索引

| 文件 | 何时读取 |
|---|---|
| `references/page-templates.md` | 创建新页面（固定视图/列表/IsolatedView）时需要完整模板 |
| `references/presenter-patterns.md` | 创建 Presenter、拆分 Presenter、文件结构、命名规范 |
| `references/communication.md` | 设计 Presenter 间通信、Service 注册方式、Notify 作用域 |
| `references/setstate-guide.md` | setState/onUpdate 机制、Context flags、Animator 动画器 |
| `references/examples.md` | 完整端到端示例（Like、列表、纯逻辑、use* API 等 8 个） |

## 更多文档

| 主题 | 文档 |
|------|------|
| 架构原理、生命周期详解 | [docs/architecture.md](./docs/architecture.md) |
| Service/Notify/AutoBind/@StateChecker | [docs/usage-guide.md](./docs/usage-guide.md) |
| 列表 Cell 复用、layoutInfo | [docs/reusable-presenter.md](./docs/reusable-presenter.md) |
| use* API 完整用法 | [docs/use-methods.md](./docs/use-methods.md) |
| @PresenterState 宏 | [docs/presenter-state-macro.md](./docs/presenter-state-macro.md) |
| Swift 6 并发模式 | [docs/swift6-patterns.md](./docs/swift6-patterns.md) |
| Demo 索引 | [docs/demo-index.md](./docs/demo-index.md) |