# 架构设计

## 设计思想：页面拆分的核心逻辑

### 页面拆分以 Presenter 为维度

DDComponent 将页面拆分为多个 Presenter，每个 Presenter 是一个独立的业务逻辑单元。最终组合而成的形态可以视作：

- **P-Tree**：Presenter 组合而成的树，代表页面的功能逻辑组织结构
- **V-Tree**：UI 展示，实际 View 的组织结果

其中 Presenter 和 View 之间为**弱关系**，需要手动绑定（或通过自动绑定）。这意味着我们可以替换为任意有相同节点的 V-Tree：

```
        P-Tree (不变)                    V-Tree A              V-Tree B
   ┌──────────────────┐           ┌──────────────────┐  ┌──────────────────┐
   │  RootPresenter   │           │    RessoRootView │  │    TTMRootView   │
   │  ├ LikePresenter │── 可绑定 ──│   ├ LikeButton   │  │   ├ LikeButton   │
   │  ├ SharePresenter│── 可绑定 ──│   ├ ShareButton  │  │   ├ ShareButton  │
   │  └ CommentList   │           │   └ CommentList   │  │   └ CommentList   │
   └──────────────────┘           └──────────────────┘  └──────────────────┘
```

这在一些功能逻辑相同但 UI 展示不同的页面中，复用程度会非常高。Resso 和 TTM 之间的功能复用就是典型场景。

### Presenter 的设计哲学

Presenter 的职责是**业务逻辑的抽象，是对逻辑的复用**。在使用过程中：

- 如果 Presenter 提供的能力非常多，且被很多功能所耦合，无法对逻辑进行合理收敛，说明该 Presenter 设计不合理
- View 不能等价于 UIView，View 表示的是**数据展示、消费的终点**，可以是 UI，也可以是其他（如埋点服务）
- 当 View 为 `Void` 类型时，Presenter 退化为**纯逻辑单元**

### 状态驱动：View 是一个状态机

UI 层的大部分内容都可以视作一个状态机。在更新视图时，最容易出现的问题是数据不对齐，特别是在复用以及有多个地方在修改视图状态时。DDComponent 借鉴 React、SwiftUI 等概念，采用**状态驱动**的视图更新模式：

- 所有状态变更通过 `setState` 统一入口
- 更新交给 Pipeline 来执行，全局统一管理
- 虽然不禁止直接修改 View，但会带来父容器无法感知修改等问题

## P-Tree 与 V-Tree 详解

### P-Tree 结构

Presenter 通过 `add(child:)` 形成树，决定页面的功能组织：

```swift
class SuperPresenter: ViewPresenter<SuperViewProtocol> {
    let likePresenter = LikePresenter()
    let sharePresenter = SharePresenter()

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        add(child: likePresenter)
        add(child: sharePresenter)
    }

    override func onBindView(_ view: SuperViewProtocol) {
        super.onBindView(view)
        likePresenter.bindView(view.likeButton)
        sharePresenter.bindView(view.shareButton)
    }

    override func onUnbindView() {
        super.onUnbindView()
        likePresenter.unbindView()
        sharePresenter.unbindView()
    }
}
```

### 关键特性

- **P-Tree 是主结构**：Presenter 通过 `add(child:)` 形成树，决定页面的功能组织
- **V-Tree 是可替换的**：相同的 P-Tree 可以绑定到不同的 V-Tree 实现
- **弱绑定**：Presenter 持有 View 的弱引用，View 不感知 Presenter 的存在
- **手动绑定**：目前需要手动绑定，这给了开发者完全的控制权

## Presenter 生命周期

所有 Presenter 都有统一的生命周期：

```
init() → onAttach → onAttachToRoot → onBindView → onUpdate (×N) → onUnbindView → onDetach → onDetachFromRoot → deinit
```

生命周期方法会**自动递归传递**到所有子 Presenter：
- `attachRootPresenter` → 递归所有 children
- `detachRootPresenter` → 递归所有 children
- `bindView` → 自动触发 `autoBindChildrenPresenterViews`
- `unbindView` → 递归所有 children

### 生命周期方法职责详解

以下是每个生命周期方法的详细职责边界。

#### 1. `init()` — 创建

**触发时机：** Presenter 初始化。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| 初始化自身属性、设置默认值 | 访问 `view`（尚未绑定） |
| RootPresenter 中通过 `typeBox()` 注册子 Presenter | 访问 `superPresenter` / `rootPresenter`（尚未挂载） |
| | 调用 `getService()` / `notify()`（Pipeline 不存在） |

#### 2. `onAttach(presenter:)` / `onAttach()` — 挂载到 P-Tree

**触发时机：** 被 `add(child:)` 加入父 Presenter。RootPresenter 使用无参版本 `onAttach()`。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **`add(child:)` 注册子 Presenter**（组建 P-Tree 的核心时机） | 访问 `view`（View 可能尚未绑定） |
| 初始化内部结构、创建子节点 | 依赖 `rootPresenter` 非空（父节点可能还没挂到 Root） |
| | 做需要 Pipeline 的操作 |

> **源码执行顺序：** `attachSuperPresenter()` 内部先调 `onAttach` → 再挂 Root → 最后 auto-bind View。所以 `onAttach` 被调用时，Root 和 View 都还没就位。

#### 3. `onAttachToRoot(rootPresenter:)` — 关联到 RootPresenter

**触发时机：** 自身或祖先挂到 RootPresenter 上时，递归所有子 Presenter。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **注册 Effect（副作用）** — Pipeline 已可用，这是注册 Effect 的最佳时机 | 操作 View 的 UI（View 可能未绑定） |
| 监听全局事件、注册全局 Notify listener | 假设 `view` 非空 |
| 启动页面级别的定时器、监听 | |
| 获取 Service 引用并缓存 | |

> **Effect 机制：** `onAttachToRoot` 时启动 effect 的 `action()`，`onDetachFromRoot` 时自动调用返回的 cancel 函数。

#### 4. `onBindView(_ view: View)` — 绑定 View

**触发时机：** `bindView(_:)` / `bindWeakView(_:)` / `tryBindView(_:)` 时。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **先调用 `super.onBindView(view)`** | 直接修改 View 的属性值（`bindView` 会自动触发首次 `onUpdate`） |
| **设置 View 的回调闭包**（`view.onButtonTapped = { ... }`） | 注册 Effect（应放在 `onAttachToRoot`） |
| 绑定子 Presenter 到对应的子 View | 调用 `add(child:)`（应在 `onAttach` 中完成） |

> **注意：** `bindView()` 内部会自动触发一次 `setState {} context: { $0.bindView() }` 来执行首次 `onUpdate`，初始数据不需要手动赋值给 View。

#### 5. `onUpdate(view: View, context: ViewUpdateContext)` — 状态同步到 View

**触发时机：** 每次 `setState {}` 后由 Pipeline 调用。可被多次调用。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **将 Presenter 状态同步到 View**（唯一正确的职责） | **修改 Presenter 的状态**（造成死循环） |
| 读取 `context` flags 做条件判断（极少需要） | **执行业务逻辑**（网络请求、页面跳转等） |
| | 修改 View 的布局约束（应通过 `context.invalidateLayout` 处理） |
| | 做耗时操作（高频滚动时频繁调用） |

> **核心原则：** `onUpdate` 是幂等的、无副作用的纯映射函数。**遗漏状态同步会导致 View 展示不一致的 bug**。

#### 6. `onUnbindView()` — 解绑 View

**触发时机：** `unbindView()`、绑定新 View（先解绑旧 View）、`detachSuperPresenter()`（自动解绑）、页面销毁。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **先调用 `super.onUnbindView()`** | 假设 `view` 非空（弱引用场景下可能已是 nil） |
| **清理 View 的回调闭包**（设 `nil` 防循环引用） | 做业务逻辑清理（应在 `onDetach` 中做） |
| 清理与 View 实例绑定的资源（定时器等） | 移除 Effect（应在 `onDetachFromRoot` 中清理） |

> **注意：** `unbindView()` 会自动递归解绑所有子 Presenter。

#### 7. `onDetach()` — 从 P-Tree 移除

**触发时机：** `removeFromSuper()` / `remove(child:)` / `detachAllPresentersRecursive()`。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| 释放 P-Tree 维度的资源（移除子 Presenter） | 访问 `view`（此时已 unbind） |
| 取消在此 Presenter 范围内注册的东西 | 访问 `superPresenter`（之后会被置 nil） |

> **执行顺序：** `detachSuperPresenter()` 内部：先 `unbindView()` → 再 `onDetach()` → 最后 `detachRootPresenter()`。

#### 8. `onDetachFromRoot()` — 脱离 RootPresenter

**触发时机：** 自身或祖先从 RootPresenter 脱离时。先递归子 Presenter，再调用自身。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| 清理全局 listener 注册 | 假设 `rootPresenter` 非空（调用时还未置 nil，但之后会） |
| 释放通过 Service 获取的引用 | |

> **Effect 自动清理：** 基类 `onDetachFromRoot()` 已调用 `effect.onDetach()`，在 `onAttachToRoot` 中用 Effect 注册的副作用无需手动清理。

#### 9. `prepareForReuse()` — 列表 Cell 复用前重置

**触发时机：** 列表 Cell 被复用时。仅 `ReusableViewPresenter` 有此方法。

| ✅ 应该做 | ❌ 不应该做 |
|---|---|
| **重置 Presenter 的所有状态**（清空数据、取消请求、重置标记） | 操作 View（此时 View 可能还是旧的） |
| 恢复到初始状态 | 调用 `setState`（重置后由外部配置数据时再触发） |

### 职责速查表

| 方法 | 核心职责 | 一句话 |
|------|---------|--------|
| `init()` | 初始化自身属性 | 设置默认值，不依赖外部 |
| `onAttach` | 组装 P-Tree | `add(child:)`，创建子 Presenter |
| `onAttachToRoot` | 注册全局依赖 | 注册 Effect、监听全局事件 |
| `onBindView` | 连接 View | 设回调闭包，绑子 View，**不**直接改 View 值 |
| `onUpdate` | 同步数据 | **仅**把状态写到 View，纯映射，无副作用 |
| `onUnbindView` | 断开 View | 清回调闭包，防止循环引用 |
| `onDetach` | 清理 P-Tree | 移除子 Presenter，清理内部引用 |
| `onDetachFromRoot` | 注销全局依赖 | 框架自动清理 Effect |
| `prepareForReuse` | 重置状态 | 清空数据，恢复到初始值 |

## 状态驱动的视图更新

### 设计动机

在更新视图时，最容易出现的问题是**数据不对齐**，特别是在复用以及有多个地方在修改视图状态时。视图本身可以认为是一个庞大的状态机，所以 DDComponent 推荐所有视图更新都采用状态驱动的形式。此概念参考了 React、SwiftUI 等框架的设计思想。

### setState 的作用

- **统一更新时机**：避免多处直接修改 View 导致数据不一致
- **批量更新**：多个 `setState` 可以合并为一次 UI 更新
- **列表场景优化**：自动处理增量更新（Diff）、动画
- **状态校验**：配合 `@StateChecker` 确保状态只在 `setState` 内部修改
- **宏简化**：配合 `@PresenterState` 宏消除 `didSet { setState {} }` 样板代码

### 基本用法

```swift
class MyPresenter: ViewPresenter<MyViewProtocol> {
    var count: Int = 0
    var title: String = ""

    // 属性变更触发更新
    var isVisible: Bool {
        didSet { setState {} }
    }

    func updateData(newCount: Int, newTitle: String) {
        setState {
            count = newCount
            title = newTitle
        } context: {
            $0.animated = true       // 带动画更新
        }
    }

    override func onUpdate(view: MyViewProtocol, context: ViewUpdateContext) {
        view.count = count
        view.title = title
        view.isVisible = isVisible
    }
}
```

### UpdatePipeline：统一的更新调度

所有状态变更交给 Pipeline 执行。只有 RootPresenter 才有唯一的 Pipeline，能够**全局统一地管理界面更新流程**：

```
setState {}
    │
    ▼
markDirty(presenter, context)    ← 标记 Presenter 为脏
    │
    ▼
updateViewIfNeeded()             ← 在合适时机触发
    │
    ▼
updateView(context:)             ← 检查 needsUpdate，调用 onUpdate
```

Pipeline 策略：
- **固定视图**：`GlobalViewUpdatePipeline` — 全局一次性更新
- **列表视图**：`PartialTransactionPipeline` — 支持增量 Diff 更新

### ViewUpdateContext 配置项

| 属性 | 作用 |
|---|---|
| `updateViewImmediately` | 立即同步更新（默认在下一个 runloop） |
| `animated` | 在 `UIView.animate` 块中执行更新 |
| `invalidateLayout` | 更新后触发 `setNeedsLayout` |
| `invalidateConstraints` | 更新后触发 `setNeedsUpdateConstraints` |
| `layoutImmediately` | 更新后立即执行 `layoutIfNeeded` |
| `invalidateDataSource` | 标记数据源变更（列表场景触发 reload） |
| `invalidateContentSize` | 标记内容尺寸变更（列表场景触发布局更新） |
| `forceDisableAnimation` | 强制禁用所有动画 |

### use* API：声明式状态管理

DDComponent 提供了一套 React Hooks 风格的 `use*` API（定义在 `ViewPresenter+Use.swift`），将状态、副作用和视图更新器声明在初始化阶段，替代分散在多个生命周期方法中的传统写法。

**核心 API：**

| 方法 | 返回类型 | 用途 |
|---|---|---|
| `useState(_:)` | `State<T>` | 创建响应式状态容器 |
| `useEffect(_:)` | `Effect` | 注册生命周期绑定的副作用 |
| `useUpdate(dependences:_:)` | `Updater` | 依赖驱动的视图更新器 |
| `useService(_:_:)` | `Effect` | 解析 Service 并传给副作用 |

> 详细用法、代码示例和 8 条关键规则见 [use* API 文档](./use-methods.md)。

## RootPresenter

`RootViewPresenter` 是 P-Tree 的根节点，有且只能有一个。它提供全局能力：

```
RootViewPresenter
├── 持有 ViewUpdatePipeline    ← 全局唯一的更新管线
├── 持有 PageServiceManager    ← 页面级服务注册/获取
├── 持有 PageNotifyManager     ← 全局广播管理
└── 实现 ServiceRegistrar      ← 服务注册接口
```

### 与普通 Presenter 的区别

| | ViewPresenter | RootViewPresenter |
|---|---|---|
| 父节点 | 有 superPresenter | 无（superPresenter 永远为 nil） |
| 生命周期 | `onAttach(presenter:)` | `onAttach()` |
| Pipeline | 从父节点继承 | 自己持有并创建 |
| Service | 从父节点查找 | 自己持有 ServiceManager |
| Notify | 委托给父节点 | 自己持有 NotifyManager |

可以重写 RootPresenter 并把业务逻辑放到 Root 中，但更建议的方式是进行细化拆分逻辑到各自的 Presenter。

## PageViewController

`PageViewController` 是 UIKit 的桥接层，负责：

1. **Presenter 初始化**：调用 `makePresenter()` 和 `presenterDidLoad()`
2. **View 绑定**：调用 `makeView()` 和 `bindView(_:)`
3. **生命周期转发**：将 `viewWillAppear` 等事件通过 Notify 广播给所有 Presenter

```swift
open class PageViewController<FrameView: UIView, Presenter: RootViewPresenterProtocol>: UIViewController {
    open func makePresenter() -> Presenter
    open func makeView() -> FrameView
    open func presenterDidLoad()    // 装配 Presenter 和 Service 的时机
}
```

### 页面生命周期事件

`PageViewController` 会自动将 ViewController 的生命周期事件广播给实现了 `PageLifecycle` 协议的 Presenter：

```swift
class MyPresenter: ViewPresenter<MyView>, PageLifecycle {
    func viewDidAppear(_ animated: Bool) {
        // 页面出现时执行，如开始上报
    }
    func viewDidDisappear(_ animated: Bool) {
        // 页面消失时执行，如暂停上报
    }
}
```

## 特殊 Presenter 类型

### ManagedViewPresenter

`ManagedViewPresenter<View>` 是 `ViewPresenter<View>` 的子类，自带独立的 `ServiceManager`。当某个 Presenter 需要自己的 Service 作用域（不依赖父 Presenter 的 Service 查找链）时使用：

```swift
class SelfContainedPresenter: ManagedViewPresenter<MyViewProtocol> {
    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        // 注册仅在此 Presenter 及其子树中可见的 Service
        register(service: LocalCacheService.self) { LocalCacheImpl() }
    }
}
```

### IsolatedViewPresenter

`IsolatedViewPresenter` 允许在非 DDComponent 页面（传统 UIViewController）中嵌入一个独立的 Presenter 组件。它自带独立的 ServiceManager、NotifyManager 和 UpdatePipeline，不依赖外部的 RootPresenter：

```swift
// 在传统 UIViewController 中
let isolated = IsolatedViewPresenter(MyLikeButton(), LikePresenter())
isolated.register(service: LikeService.self) { LikeServiceImpl() }
view.addSubview(isolated.view)

// 手动转发生命周期
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isolated.notifyGlobal(listener: PageLifecycle.self) {
        $0.viewDidAppear(animated)
    }
}
```

### Shadow Presenter（CollectionItemPresenter 内部）

Shadow Presenter 是 `CollectionItemPresenter` 的**内部实现细节**，用于解决列表 Cell 复用场景下的生命周期管理：

```
Cell 显示时:
  CollectionItemPresenter
    └── ShadowPresenter
          ├── bindView(cell)     → 触发 onBindView
          └── onUpdate(cell)     → 触发 onUpdate

Cell 回收时:
  CollectionItemPresenter
    └── ShadowPresenter
          └── unbindView()       → 触发 onUnbindView
          └── prepareForReuse()  → 重置状态
```

开发者通常不需要直接操作 Shadow Presenter，框架自动处理绑定/解绑。

## 内部通信机制

### 设计背景

页面拆分后，各个模块的通信问题会非常麻烦。传统做法是直接通过引用调用，但拆分后 Presenter 之间不应该互相持有引用，这会导致新的耦合。DDComponent 提供了两种解耦的通信方式：

### Service：页面级能力桥接

Service 提供**页面级别**的组件化服务功能，用于可替换的外部能力（网络请求、路由跳转、埋点上报、数据持久化）：

```swift
// 注册
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, { MockDataLoaderImpl() })
}

// 获取
getService(LikeService.self)?.toggleLike(...)
```

Service 查找链：当前 Presenter → superPresenter → ... → RootPresenter → 全局降级服务

### Notify：广播通信

基于协议的多播通信，用于 Presenter 间通信。按作用域分为：

| 作用域 | 方法 | 范围 |
|---|---|---|
| `.global` | `notifyGlobal()` | 从 Root 广播到所有 P-Tree 中的 Presenter |
| `.children` | `notifyChildren()` | 向下广播到所有子模块 |
| `.childrenAndSelf` | — | 向下广播，包括自身 |
| `.parents` | `notifyParents()` | 向上广播到父链 |
| `.reusable` | `notifyReusable()` | 广播到最近的复用容器范围 |

```swift
// 定义监听协议
protocol LikeListener: AnyObject {
    func onLikeChanged(isLiked: Bool, count: Int)
}

// 发送广播
notify(listener: LikeListener.self) {
    $0.onLikeChanged(isLiked: true, count: 10)
}

// 接收广播（实现对应协议即可）
extension MyPresenter: LikeListener {
    func onLikeChanged(isLiked: Bool, count: Int) { ... }
}
```

### 通信方式选择

| 场景 | 用 Notify | 用 Service |
|---|---|---|
| 父 ↔ 子 Presenter 通信 | ✅ | ❌ |
| 网络请求 | ❌ | ✅ |
| 页面跳转 | ❌ | ✅ |
| 埋点上报 | ❌ | ✅ |
| 全局事件（主题切换、登录状态） | ✅ | ❌ |

## 类关系总览

```
                    ┌──────────────────────┐
                    │  ViewPresentable     │  (协议)
                    │  - P-Tree 管理       │
                    │  - View 绑定         │
                    │  - 生命周期          │
                    │  - Notify / Service  │
                    └──────────┬───────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
   ┌─────▼──────────┐  ┌──────▼──────────┐  ┌───────▼──────────────┐
   │ ViewPresenter  │  │ RootView-       │  │ ReusableView-        │
   │ <V> (基类)     │  │ Presenter<V>    │  │ Presenter<V>         │
   └──┬──┬──────────┘  │ (根节点)        │  │ (列表复用)           │
      │  │              └────────────────┘  └──┬───────────────────┘
      │  │                                      │
 ┌────▼┐ │ ┌──────────────────────┐  ┌──────────▼──────────────┐
 │IdVG │ │ │ PageViewController   │  │ CollectionPresenter<V>  │
 │Pres.│ │ │ (UIKit 桥接)         │  │ (Collection/TableView)  │
 └─────┘ │ └──────────────────────┘  └─────────────────────────┘
         │
  ┌──────▼───────────┐  ┌──────────────────┐
  │ ManagedView-     │  │ IsolatedView-    │
  │ Presenter<V>     │  │ Presenter        │
  │ (自带 Service)   │  │ (独立组件)       │
  └──────────────────┘  └──────────────────┘
```

## 相关文档

- [使用指南](./usage-guide.md) — 固定视图、列表视图、装配方式
- [复用 Presenter](./reusable-presenter.md) — 列表 Cell 复用、增量更新引擎
- [use* API](./use-methods.md) — 声明式状态管理详细用法
- [Swift 6 并发模式](./swift6-patterns.md) — lazy var、MainActor、Sendable
- [@PresenterState 宏](./presenter-state-macro.md) — 简化状态声明
- [Demo 索引](./demo-index.md) — 所有示例 Demo 列表
