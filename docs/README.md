# DDComponent — PagePresenter 页面拆分框架

DDComponent 是一个基于 **MVP（Model-View-Presenter）** 模式的 iOS 页面拆分框架，帮助你将复杂的页面拆分为独立、可复用、可插拔的功能模块。

## 背景：为什么需要页面拆分？

随着业务趋于复杂，一个视图内部往往包含多个方向的业务逻辑，传统的 MVC 开发模式面临三个核心问题：

1. **代码冲突与复杂度失控**：所有人都在改同一个 ViewController，导致冲突和复杂度直线上升，所有业务都被卡在关键开发上。
2. **功能边界模糊**：复杂业务场景成为"金三角地区"，谁都不愿意对质量负责，设计、维护成为严重问题。
3. **跨 App 复用困难**：例如 Resso 和 TTM 之间，逻辑功能一致但 UI 差异很大，需要功能在逻辑层可复用，在 UI 层可替换。

### 框架目标

1. **标准化功能拆分**：提供统一的 Presenter 拆分框架，让每个功能独立开发
2. **动态插拔能力**：支持按需装配功能模块，不修改已有代码即可扩展
3. **UI 灵活绑定**：相同的业务逻辑可以绑定到不同的 UI 实现
4. **高度可复用**：模块不依赖特定页面，可在不同场景复用

## 什么是 MVP？框架中的 MVP 解读

### Presenter：业务逻辑的抽象

Presenter 主要负责业务逻辑，它非常像 MVC 中的 Controller，但与 MVVM 中的 ViewModel 并不相同——ViewModel 更多提供数据驱动和双向绑定能力，而 **Presenter 体现的是业务逻辑的抽象，是对逻辑的复用**。

当 Presenter 提供的能力非常多且被很多功能耦合，无法对逻辑进行合理收敛时，说明该 Presenter 设计不合理。

### View：数据消费的终点，而非 UIView

在 MVC 中 View 往往指 `UIView`，但在 MVP 中 **View 不能等价于 UIView**。View 表示的是数据展示、消费的终点，可以是 UI，也可以是其他。所以 **View 一般都定义为协议，而非真正的实体类型**。

```swift
// View 是协议，不是 UIView
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    var onLikeTapped: (() -> Void)? { get set }
}

// 任何实现该协议的对象都可以作为 View
class BigLikeButton: UIView, LikeViewProtocol { ... }
class SmallLikeButton: UIView, LikeViewProtocol { ... }
```

### 特殊场景：View 为 Void

当 View 为 `Void` 类型时，Presenter 就退化为一个**纯逻辑单元**，不绑定任何 UI。例如埋点上报：

```swift
// View 为数据消费方（TraceService），而非 UI
protocol TraceService {
    func trace(_ dict: [String: Any])
}

class LifecycleTracePresenter: ViewPresenter<TraceService>, PageLifecycle {
    func onAttach() {
        // View 是一个 Service，在挂载时立即绑定
        bindView(getService(TraceService.self)!)
    }

    func viewDidDisappear(_ animated: Bool) {
        view?.trace(["event": "page_disappear"])
    }
}
```

## 核心概念：P-Tree 与 V-Tree

框架的核心设计是 **双树结构**——页面拆分以 Presenter 的维度进行：

```
P-Tree (Presenter 树)          V-Tree (View 树)
┌─────────────────┐          ┌─────────────────┐
│  RootPresenter  │ - - - - │    RootView     │
│  ├ LikePresenter │ - - - - │   ├ LikeButton  │
│  ├ SharePresenter│ - - - - │   ├ ShareButton │
│  └ CommentPresenter│ - - - │   └ CommentList │
└─────────────────┘          └─────────────────┘
```

- **P-Tree**：Presenter 组合而成的树，代表页面的功能逻辑组织结构
- **V-Tree**：UI 展示，实际 View 的组织结果
- **两者之间是弱关系**：Presenter 和 View 之间需要手动绑定（或自动绑定），相同的 P-Tree 可以替换为任意有相同节点的 V-Tree

这在一些功能逻辑相同但 UI 展示不同的页面中，复用程度会非常高。例如 Resso 和 TTM 的同一个功能，只需替换 UI 绑定，业务逻辑完全不变。

## 快速示例：Like 功能

下面通过一个完整的 Like 功能展示框架的核心用法：

```swift
// 1. 定义 View 协议（数据消费的终点）
protocol LikeViewProtocol: AnyObject {
    var isLiked: Bool { get set }
    var likeCount: Int { get set }
    func set(isLiked: Bool, animated: Bool)
    var onLikeTapped: (() -> Void)? { get set }
}

// 2. 定义监听协议（对外广播）
protocol LikePresenterListener: AnyObject {
    func onLikeInfoChanged(presenter: LikePresenter, isLiked: Bool, likeCount: Int)
}

// 3. 实现 Presenter（业务逻辑）
class LikePresenter: ViewPresenter<LikeViewProtocol> {
    var resource: LikableResourceProtocol?

    struct LikeInfo {
        var isLiked: Bool = false
        var likeCount: Int = 0
    }

    private var _likeInfo = LikeInfo()
    var likeInfo: LikeInfo {
        set {
            // 需要触发 UI 更新时，必须通过 setState
            setState { _likeInfo = newValue } context: { $0.animated = false }
        }
        get { _likeInfo }
    }

    func toggleLike() {
        guard let resource, let service = getService(LikeService.self) else { return }
        service.toggleLike(resource: resource, isLiked: likeInfo.isLiked,
                          likeCount: likeInfo.likeCount) { [weak self] isLiked, likeCount, error in
            guard let self else { return }
            self.set(likeInfo: LikeInfo(isLiked: isLiked, likeCount: likeCount), animated: true)
            // 向外部广播 Like 变更消息
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
}

// 4. 装配到父 Presenter 中
class SuperPresenter: ViewPresenter<SuperViewProtocol> {
    let likePresenter = LikePresenter()

    override func onAttach(presenter: ViewPresentable) {
        super.onAttach(presenter: presenter)
        add(child: likePresenter)   // 必须加入 children 才能形成 P-Tree
    }

    override func onBindView(_ view: SuperViewProtocol) {
        super.onBindView(view)
        likePresenter.bindView(view.likeButton)  // 绑定对应的 View
    }

    override func onUnbindView() {
        super.onUnbindView()
        likePresenter.unbindView()  // 解绑 View
    }
}

// 5. 创建 ViewController
class MyViewController: PageViewController<MyRootView, MyRootPresenter, MyRootPresenterView> {
    override var pageInstallers: PageInstaller {
        ServiceInstaller(LikeService.self, { LikeServiceImpl() })
        PresenterInstaller(lazyLoad: true, { LikePresenter() })
    }
}
```

## 文档导航

| 文档 | 内容 |
|---|---|
| [架构设计](./architecture.md) | P-Tree/V-Tree 详解、生命周期、状态驱动、UpdatePipeline、Service 与 Notify |
| [使用指南](./usage-guide.md) | 固定视图、列表视图、Service/Notify 使用、装配方式 |
| [复用 Presenter](./reusable-presenter.md) | 列表 Cell 复用、CollectionPresenter 体系、增量更新引擎 |

## 安装

```ruby
# Podfile
pod 'DDComponent'
```

## 项目结构

```
DDComponent/
  Classes/
    ViewPresenter.swift              # 所有 Presenter 的基类
    RootViewPresenter.swift          # 根 Presenter，管理 Service 和 Notify
    PageViewController.swift         # UIKit 桥接基类
    ViewGroupPresenter.swift         # 支持按标识符存取子 Presenter
    PresenterInstaller.swift         # 声明式装配 DSL（Result Builder）
    ViewUpdateContext.swift          # 视图更新配置
    ViewPresenterNotifiable.swift    # 通知广播系统
    ViewAutoBind.swift               # 自动 View 绑定
    Service.swift                    # 页面级服务（DI）
    PageServiceManager.swift         # 服务管理器
    PageNotifyManager.swift          # 通知管理器
    ManagedViewPresenter.swift       # 托管型 Presenter
    IsolatedViewPresenter.swift      # 隔离型 Presenter
    UpdatePipeline/                  # 更新管线实现
    Reusable/                        # 可复用 Presenter（列表场景）
      ReusableViewPresenter.swift
      CollectionPresenters/          # 集合视图抽象层
      UITableView/                   # UITableView 实现
      UICollectionView/              # UICollectionView 实现
      PartialUpdateEngine/           # 增量更新引擎
```

## 最低要求

- iOS 13.0+
- Swift 5.7+
- Xcode 14.0+