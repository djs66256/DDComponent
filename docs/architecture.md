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
        // 必须加入 children 才能形成 P-Tree
        add(child: likePresenter)
        add(child: sharePresenter)
    }

    override func onBindView(_ view: SuperViewProtocol) {
        super.onBindView(view)
        // 绑定对应的 V-Tree 节点
        likePresenter.bindView(view.likeButton)
        sharePresenter.bindView(view.shareButton)
    }

    override func onUnbindView() {
        super.onUnbindView()
        // 解绑时也要清理
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

所有 Presenter 都有统一的生命周期，分为两个维度：

### 结构生命周期（P-Tree 维度）

涉及 Presenter 在 P-Tree 中的挂载和卸载：

| 方法 | 触发时机 | 用途 |
|---|---|---|
| `onAttach(presenter:)` | 被 `add(child:)` 加入父 Presenter | 注册子 Presenter，初始化内部结构 |
| `onDetach()` | 通过 `removeFromSuper()` 或 `remove(child:)` 从 P-Tree 移除 | 清理资源 |

### 根节点生命周期

涉及 Presenter 与 RootPresenter 的关联：

| 方法 | 触发时机 | 用途 |
|---|---|---|
| `onAttachToRoot(rootPresenter:)` | 关联到 RootPresenter | 注册 Effect（副作用），监听全局事件 |
| `onDetachFromRoot()` | 从 RootPresenter 脱离 | 清理 Effect |

### View 绑定生命周期

涉及 Presenter 与 View 的绑定和解绑：

| 方法 | 触发时机 | 用途 |
|---|---|---|
| `onBindView(_:)` | 调用 `bindView(_:)` 绑定 View | 设置 View 的回调，传递初始数据 |
| `onUnbindView()` | 解绑 View 或页面销毁 | 清理 View 回调，防止循环引用 |

解绑会发生在：
1. 手动调用 `unbindView()`
2. 绑定新的 View（先解绑旧的）
3. 页面销毁时

### 视图更新生命周期

涉及数据变更到 UI 更新的过程：

| 方法 | 触发时机 | 用途 |
|---|---|---|
| `onUpdate(view:context:)` | `setState {}` 触发 | 将状态同步到 View |

`onUpdate` 会在合适的时机更新视图，该时机会随着 `ViewUpdateContext` 配置与所处场景不同而不同，包括但不限于：
1. 立即更新
2. 在下一个 RunLoop 更新
3. 列表增量更新、异步计算后的时机

### 完整生命周期流转图

```
     init()
       │
       ▼
  onAttach(presenter:)  ← 被 add(child:) 加入 P-Tree
       │
       ▼
  onAttachToRoot()      ← 关联到 RootPresenter
       │
       ▼
  onBindView(_:)        ← bindView(_:) 绑定 View
       │
       ▼
  ┌─ onUpdate(view:context:) ─┐  ← setState {} 触发，可多次执行
  │    (状态变更 → UI 更新)     │
  └────────────────────────────┘
       │
       ▼
  onUnbindView()        ← unbindView() 或页面销毁时
       │
       ▼
  onDetachFromRoot()
       │
       ▼
  onDetach()            ← removeFromSuper() 或页面销毁时
       │
       ▼
     deinit
```

### 生命周期递归传递

生命周期方法会**自动递归传递**到所有子 Presenter：

- `attachRootPresenter` → 递归所有 children
- `detachRootPresenter` → 递归所有 children
- `bindView` → 自动触发 `autoBindChildrenPresenterViews`
- `unbindView` → 递归所有 children

## 状态驱动的视图更新

### 设计动机

在更新视图时，最容易出现的问题是**数据不对齐**，特别是在复用以及有多个地方在修改视图状态时。视图本身可以认为是一个庞大的状态机，所以 DDComponent 推荐所有视图更新都采用状态驱动的形式。此概念参考了 React、SwiftUI 等框架的设计思想。

### setState 的作用

- **统一更新时机**：避免多处直接修改 View 导致数据不一致
- **批量更新**：多个 `setState` 可以合并为一次 UI 更新
- **列表场景优化**：自动处理增量更新（Diff）、动画
- **状态校验**：配合 `@StateChecker` 确保状态只在 `setState` 内部修改

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

所有状态变更更新都会交给 Pipeline 来执行。只有 RootPresenter 才有唯一的 Pipeline，这样的好处是能够**全局统一地管理界面更新流程**，特别是在列表场景下，会有不同的更新方式。

虽然形式上不禁止直接修改 View，但这样会带来一些问题，比如父容器无法感知修改。建议所有更新视图都通过 `setState` 方式进行。

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
- **列表视图**：`PartialTrasactionPipeline` — 支持增量 Diff 更新

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
open class PageViewController<FrameView, Presenter, View>: UIViewController {
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

## 内部通信机制

### 设计背景

页面拆分后，各个模块的通信问题会非常麻烦。传统做法是直接通过引用调用，但拆分后 Presenter 之间不应该互相持有引用，这会导致新的耦合。所以 DDComponent 提供了两种解耦的通信方式：

### Service：页面级能力桥接

有很多能力属于提供一定功能，而非业务自身的逻辑，比如埋点、页面跳转等。这些功能又无法定义为全局能力，因为需要页面相关信息进行填补。

Service 提供**页面级别**的组件化服务功能，该能力只会在单一页面内部生效：

```swift
// 注册（2 种方式）
// 方式一：在 presenterDidLoad 中手动注册
override func presenterDidLoad() {
    super.presenterDidLoad()
    register(service: LikeService.self) { LikeServiceImpl() }
}

// 方式二：在 pageInstallers 中声明式注册
@PageInstallerBuilder override var pageInstallers: PageInstaller {
    ServiceInstaller(LikeService.self, { LikeServiceImpl() })
    ServiceInstaller(DataLoader.self, { MockDataLoaderImpl() })
}

// 获取（在任意 Presenter 中）
getService(LikeService.self)?.toggleLike(...)
```

Service 查找链：当前 Presenter → superPresenter → ... → RootPresenter → 全局降级服务

### Notify：广播通信

页面拆分后，各个模块的通信问题会非常麻烦，所以通过广播的形式去简化消息传递。基于协议的多播通信，按作用域分为：

| 作用域 | 方法 | 范围 |
|---|---|---|
| `.global` | `notifyGlobal()` | 从 Root 广播到所有 P-Tree 中的 Presenter，也会发送到手动注册的接收方 |
| `.children` | `notifyChildren()` | 向下广播到所有子模块（递归实现） |
| `.childrenAndSelf` | — | 向下广播，包括自身 |
| `.parents` | `notifyParents()` | 向上广播到父链 |
| `.reusable` | `notifyReusable()` | 广播到最近的复用容器范围内 |

**发送方**需要判断消息接收主体应该包括哪些——是全局还是子模块。在 reusable view 场景下，往往只想要通知自己模块下的所有 Presenter 进行更新操作，此时通过向下广播就非常适合。

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
    func onLikeChanged(isLiked: Bool, count: Int) {
        // 处理通知
    }
}
```

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
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼─────────┐ ┌───▼──────────┐ ┌───▼────────────────┐
    │ ViewPresenter<V>  │ │ RootView-    │ │ ReusableView-      │
    │ (基类)            │ │ Presenter<V> │ │ Presenter<V>       │
    │                   │ │ (根节点)     │ │ (列表复用)         │
    └───┬───────────────┘ └──┬───────────┘ └──┬─────────────────┘
        │                    │                 │
 ┌──────▼──────────┐  ┌──────▼──────────┐  ┌──▼──────────────────┐
 │ IdentifierView- │  │ PageViewController│ │ CollectionPresenter │
 │ GroupPresenter  │  │ (UIKit 桥接)    │  │ (UICollectionView)  │
 │ (标识符存取)    │  └─────────────────┘  │ UITableView...      │
 └─────────────────┘                        └─────────────────────┘
```